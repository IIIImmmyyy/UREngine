#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$PackagePath,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repository = 'IIIImmmyyy/UREngine'
$website = 'https://www.ur-engine.com'

function Invoke-Gh([string[]]$Arguments) {
    $output = & gh @Arguments
    if ($LASTEXITCODE -ne 0) { throw "GitHub CLI failed: gh $($Arguments -join ' ')" }
    return $output
}

function Assert-Asset($Asset, [System.IO.FileInfo]$File) {
    $digest = 'sha256:' + (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($Asset.state -ne 'uploaded' -or $Asset.size -ne $File.Length -or $Asset.digest -ne $digest) {
        throw "GitHub asset differs from the verified package: $($File.Name). Existing assets were not replaced."
    }
}

$manifest = Invoke-RestMethod -Uri "$website/downloads/studio/latest.json" -Headers @{ 'Cache-Control' = 'no-cache' }
$version = [string]$manifest.version
if ($version -cnotmatch '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$') {
    throw 'The official release manifest has an invalid stable version.'
}
$fileName = "UREngine-Studio-$version-win-x64.zip"
$downloadPattern = '^/downloads/studio/[0-9a-fA-F-]{36}/' + [regex]::Escape($fileName) + '$'
if ($manifest.fileName -cne $fileName -or $manifest.downloadUrl -cnotmatch $downloadPattern -or
    $manifest.sha256 -notmatch '^[a-fA-F0-9]{64}$' -or $manifest.fileSizeBytes -le 0 -or
    $manifest.notes.zhCN -isnot [string] -or $manifest.notes.en -isnot [string]) {
    throw 'The official release manifest has invalid download metadata.'
}

if (-not $DryRun) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw 'Install GitHub CLI first: winget install --id GitHub.cli -e. Then run: gh auth login --hostname github.com'
    }
    Invoke-Gh @('auth', 'status', '--hostname', 'github.com') | Out-Host
}

$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$workDirectory = Join-Path $tempRoot ('UREngine-GitHub-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workDirectory | Out-Null
try {
    if ([string]::IsNullOrWhiteSpace($PackagePath)) {
        $PackagePath = Join-Path $workDirectory $fileName
        Write-Host "Downloading Studio $version from the official website..."
        Invoke-WebRequest -Uri ($website + $manifest.downloadUrl) -OutFile $PackagePath
    }
    $package = Get-Item -LiteralPath $PackagePath
    $hash = (Get-FileHash -LiteralPath $package.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($package.Name -cne $fileName -or $package.Length -ne $manifest.fileSizeBytes -or $hash -ne $manifest.sha256) {
        throw 'Package filename, size or SHA-256 does not match the latest official release.'
    }

    $archive = [IO.Compression.ZipFile]::OpenRead($package.FullName)
    try {
        foreach ($name in @('studio-release.json', 'UREngine.Studio.exe', 'UREngine.Studio.Sidecar.exe', 'Assets/UREngine.Assets.exe')) {
            if (-not $archive.GetEntry($name)) { throw "Package is missing $name." }
        }
        $reader = [IO.StreamReader]::new($archive.GetEntry('studio-release.json').Open())
        try { $inside = $reader.ReadToEnd() | ConvertFrom-Json } finally { $reader.Dispose() }
        if ($inside.product -cne 'UREngine Studio' -or $inside.version -cne $version -or $inside.platform -cne 'win-x64') {
            throw 'The ZIP manifest does not match the official Studio release.'
        }
    } finally { $archive.Dispose() }

    $tag = "studio-v$version"
    Write-Host "Verified $fileName ($($package.Length) bytes), SHA-256: $hash"
    if ($DryRun) {
        Write-Host "Dry run passed. Would publish https://github.com/$repository/releases/tag/$tag"
        return
    }

    $checksumPath = Join-Path $workDirectory ($fileName + '.sha256')
    [IO.File]::WriteAllText($checksumPath, "$hash  $fileName`n", [Text.UTF8Encoding]::new($false))
    $notesPath = Join-Path $workDirectory 'release-notes.md'
    $releaseNotes = @"
## UREngine Studio $version

[官方网站 / Official website]($website) · [使用指南 / Guide]($website/guide/) · [申请试用 / Request trial]($website/trial/)

### 更新内容

$($manifest.notes.zhCN)

### What's new

$($manifest.notes.en)

### 下载与使用 / Download and run

- Windows x64 portable ZIP: **$fileName**. Extract the entire ZIP and run **UREngine.Studio.exe**.
- Windows x64 便携版：完整解压 ZIP，运行 **UREngine.Studio.exe**。请保留附带目录和文件。
- Activation and network access are required for decompilation. 反编译需要激活与联网。
- Download the Studio ZIP under Assets; GitHub's Source code archives contain this documentation repository.
- 请下载 Assets 中的 Studio ZIP；GitHub 自动生成的 Source code 压缩包是本介绍仓库。

SHA-256: **$hash**
"@
    [IO.File]::WriteAllText($notesPath, $releaseNotes, [Text.UTF8Encoding]::new($false))

    $releases = Invoke-Gh @('api', "repos/$repository/releases?per_page=100", '--paginate', '--slurp') | ConvertFrom-Json | ForEach-Object { $_ }
    $matchingReleases = @($releases | Where-Object tag_name -CEQ $tag)
    if ($matchingReleases.Count -gt 1) { throw "Multiple releases use $tag; resolve them in GitHub first." }
    if ($matchingReleases.Count -eq 0) {
        Invoke-Gh @('release', 'create', $tag, '--repo', $repository, '--draft', '--title', "UREngine Studio $version", '--notes-file', $notesPath) | Out-Host
        $created = Invoke-Gh @('release', 'view', $tag, '--repo', $repository, '--json', 'databaseId') | ConvertFrom-Json
        $release = Invoke-Gh @('api', "repos/$repository/releases/$($created.databaseId)") | ConvertFrom-Json
    } else { $release = $matchingReleases[0] }

    $files = @($package, (Get-Item -LiteralPath $checksumPath))
    foreach ($file in $files) {
        $assets = @($release.assets | Where-Object name -CEQ $file.Name)
        if ($assets.Count -eq 1) {
            Assert-Asset $assets[0] $file
        } elseif ($assets.Count -gt 1 -or -not $release.draft) {
            throw "Published release or duplicate asset needs manual review: $($file.Name). Nothing was overwritten."
        } else {
            Invoke-Gh @('release', 'upload', $tag, $file.FullName, '--repo', $repository) | Out-Host
        }
    }

    $verified = Invoke-Gh @('api', "repos/$repository/releases/$($release.id)") | ConvertFrom-Json
    foreach ($file in $files) {
        $assets = @($verified.assets | Where-Object name -CEQ $file.Name)
        if ($assets.Count -ne 1) { throw "Uploaded asset not found: $($file.Name). Release remains a draft." }
        Assert-Asset $assets[0] $file
    }
    if ($verified.draft) {
        Invoke-Gh @('release', 'edit', $tag, '--repo', $repository, '--draft=false', '--latest', '--notes-file', $notesPath) | Out-Host
        $verified = Invoke-Gh @('api', "repos/$repository/releases/$($release.id)") | ConvertFrom-Json
        if ($verified.draft) { throw 'GitHub still reports a draft. Rerun the script to resume.' }
    }
    Write-Host "Published and verified: $($verified.html_url)"
} finally {
    $resolvedWork = [IO.Path]::GetFullPath($workDirectory)
    if ([IO.Path]::GetDirectoryName($resolvedWork).TrimEnd('\', '/') -ne $tempRoot.TrimEnd('\', '/') -or
        [IO.Path]::GetFileName($resolvedWork) -notmatch '^UREngine-GitHub-[a-f0-9]{32}$') {
        throw 'Refusing to clean a path outside the temporary release directory.'
    }
    Remove-Item -LiteralPath $resolvedWork -Recurse -Force
}
