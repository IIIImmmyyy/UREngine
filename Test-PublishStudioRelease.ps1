#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('UREngine-ReleaseTest-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$packagePath = Join-Path $testRoot 'UREngine-Studio-1.2.3-win-x64.zip'
$publisher = Join-Path $PSScriptRoot 'Publish-StudioRelease.ps1'
$global:ureStudioReleaseTestCase = $null
$script:passed = 0

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}
function New-Case {
    $global:ureStudioReleaseTestCase = @{
        Release = $null; Mutations = 0; FailUpload = $false; FailApi = $false; Downloads = 0; SourcePath = $packagePath
        Manifest = @{
            version = '1.2.3'; fileName = 'UREngine-Studio-1.2.3-win-x64.zip'
            fileSizeBytes = (Get-Item -LiteralPath $packagePath).Length
            sha256 = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
            downloadUrl = '/downloads/studio/11111111-2222-3333-4444-555555555555/UREngine-Studio-1.2.3-win-x64.zip'
            notes = @{ zhCN = '测试发布'; en = 'Test release' }
        }
    }
}
function Invoke-RestMethod($Uri, $Headers) {
    Assert ($Uri -ceq 'https://www.ur-engine.com/downloads/studio/latest.json') 'Unexpected manifest endpoint.'
    return [pscustomobject]$global:ureStudioReleaseTestCase.Manifest
}
function Invoke-WebRequest($Uri, $OutFile) {
    Assert ($Uri -ceq ('https://www.ur-engine.com' + $global:ureStudioReleaseTestCase.Manifest.downloadUrl)) 'Unexpected download URL.'
    $global:ureStudioReleaseTestCase.Downloads++
    Copy-Item -LiteralPath $global:ureStudioReleaseTestCase.SourcePath -Destination $OutFile
}
function gh {
    $global:LASTEXITCODE = 0
    $a = @($args)
    if ($a[0] -eq 'auth') { return }
    if ($a[0] -eq 'api') {
        if ($global:ureStudioReleaseTestCase.FailApi) { $global:LASTEXITCODE = 1; return }
        if ($a[1] -ceq 'repos/IIIImmmyyy/UREngine/releases?per_page=100') {
            Assert ($a -contains '--paginate' -and $a -contains '--slurp' -and $a -notcontains '--jq') 'Invalid pagination flags.'
            $items = if ($null -eq $global:ureStudioReleaseTestCase.Release) { @() } else { @($global:ureStudioReleaseTestCase.Release) }
            return '[[{"id":1,"tag_name":"older-version","draft":false,"assets":[]}],' + (ConvertTo-Json -InputObject @($items) -Depth 10) + ']'
        }
        Assert ($a[1] -ceq 'repos/IIIImmmyyy/UREngine/releases/77') 'Unexpected release endpoint.'
        return $global:ureStudioReleaseTestCase.Release | ConvertTo-Json -Depth 10
    }
    Assert ($a[0] -eq 'release' -and $a[2] -ceq 'studio-v1.2.3') 'Wrong release/tag.'
    Assert ($a[$a.IndexOf('--repo') + 1] -ceq 'IIIImmmyyy/UREngine') 'Wrong target repository.'
    switch ($a[1]) {
        'create' {
            Assert ($a -contains '--draft') 'Release must start as a draft.'
            $notes = Get-Content -LiteralPath $a[$a.IndexOf('--notes-file') + 1] -Raw
            Assert ($notes.Contains('测试发布') -and $notes.Contains('Test release')) 'Missing bilingual notes.'
            $global:ureStudioReleaseTestCase.Mutations++
            $global:ureStudioReleaseTestCase.Release = @{ id = 77; tag_name = 'studio-v1.2.3'; draft = $true; assets = @(); html_url = 'https://github.com/IIIImmmyyy/UREngine/releases/tag/studio-v1.2.3' }
        }
        'view' { return '{"databaseId":77}' }
        'upload' {
            $file = Get-Item -LiteralPath $a[3]
            if ($global:ureStudioReleaseTestCase.FailUpload -and $file.Extension -eq '.sha256') {
                $global:ureStudioReleaseTestCase.FailUpload = $false
                $global:LASTEXITCODE = 1
                return
            }
            $global:ureStudioReleaseTestCase.Mutations++
            $global:ureStudioReleaseTestCase.Release.assets += @{
                name = $file.Name; size = $file.Length; state = 'uploaded'
                digest = 'sha256:' + (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
            }
        }
        'edit' {
            Assert ($global:ureStudioReleaseTestCase.Release.assets.Count -eq 2) 'Do not publish before both assets exist.'
            Assert ($a -contains '--draft=false' -and $a -contains '--latest') 'Missing publication flags.'
            $global:ureStudioReleaseTestCase.Mutations++
            $global:ureStudioReleaseTestCase.Release.draft = $false
        }
        default { throw 'Unexpected GitHub CLI command.' }
    }
}
function Expect-Failure([scriptblock]$Action, [string]$Message) {
    $caught = $null
    try { & $Action } catch { $caught = $_.Exception.Message }
    Assert ($null -ne $caught -and $caught.Contains($Message)) "Expected '$Message'; received '$caught'."
    $script:passed++
}

try {
    $archive = [IO.Compression.ZipFile]::Open($packagePath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($name in @('UREngine.Studio.exe', 'UREngine.Studio.Sidecar.exe', 'Assets/UREngine.Assets.exe', 'studio-release.json')) {
            $writer = [IO.StreamWriter]::new($archive.CreateEntry($name).Open())
            try {
                $content = if ($name -eq 'studio-release.json') { '{"product":"UREngine Studio","version":"1.2.3","platform":"win-x64"}' } else { 'test-only fixture' }
                $writer.Write($content)
            } finally { $writer.Dispose() }
        }
    } finally { $archive.Dispose() }

    New-Case
    & $publisher -DryRun
    Assert ($global:ureStudioReleaseTestCase.Mutations -eq 0 -and $global:ureStudioReleaseTestCase.Downloads -eq 1) 'Dry run must download and verify without publishing.'
    $script:passed++

    New-Case
    $global:ureStudioReleaseTestCase.Manifest.sha256 = '0' * 64
    Expect-Failure { & $publisher -PackagePath $packagePath -DryRun } 'does not match'
    Assert ($global:ureStudioReleaseTestCase.Mutations -eq 0) 'Invalid hash caused a mutation.'

    New-Case
    $global:ureStudioReleaseTestCase.Manifest.downloadUrl = 'https://untrusted.example/package.zip'
    Expect-Failure { & $publisher -PackagePath $packagePath -DryRun } 'invalid download metadata'

    New-Case
    $global:ureStudioReleaseTestCase.Manifest.version = '../unsafe'
    Expect-Failure { & $publisher -PackagePath $packagePath -DryRun } 'invalid stable version'

    New-Case
    & $publisher -PackagePath $packagePath
    Assert (-not $global:ureStudioReleaseTestCase.Release.draft -and $global:ureStudioReleaseTestCase.Mutations -eq 4) 'Initial release did not complete.'
    $script:passed++
    $before = $global:ureStudioReleaseTestCase.Mutations
    & $publisher -PackagePath $packagePath
    Assert ($global:ureStudioReleaseTestCase.Mutations -eq $before) 'Repeated run mutated an existing release.'
    $script:passed++

    $global:ureStudioReleaseTestCase.Release.assets[0].digest = 'sha256:' + ('0' * 64)
    Expect-Failure { & $publisher -PackagePath $packagePath } 'differs from the verified package'
    Assert ($global:ureStudioReleaseTestCase.Mutations -eq $before) 'Mismatched published asset was overwritten.'

    New-Case
    $global:ureStudioReleaseTestCase.FailUpload = $true
    Expect-Failure { & $publisher -PackagePath $packagePath } 'GitHub CLI failed'
    Assert ($global:ureStudioReleaseTestCase.Release.draft -and $global:ureStudioReleaseTestCase.Release.assets.Count -eq 1) 'Failed upload published an incomplete release.'
    & $publisher -PackagePath $packagePath
    Assert (-not $global:ureStudioReleaseTestCase.Release.draft -and $global:ureStudioReleaseTestCase.Release.assets.Count -eq 2 -and $global:ureStudioReleaseTestCase.Mutations -eq 4) 'Retry duplicated an asset or failed to resume.'
    $script:passed++

    $global:ureStudioReleaseTestCase.Release.assets = @($global:ureStudioReleaseTestCase.Release.assets[0])
    Expect-Failure { & $publisher -PackagePath $packagePath } 'needs manual review'

    New-Case
    $global:ureStudioReleaseTestCase.FailApi = $true
    Expect-Failure { & $publisher -PackagePath $packagePath } 'GitHub CLI failed'
    Assert ($global:ureStudioReleaseTestCase.Mutations -eq 0) 'API failure was mistaken for an absent release.'

    Write-Host "PASS: $script:passed release script checks; no network access or GitHub mutations."
} finally {
    $resolved = [IO.Path]::GetFullPath($testRoot)
    Assert ([IO.Path]::GetDirectoryName($resolved).TrimEnd('\', '/') -eq [IO.Path]::GetTempPath().TrimEnd('\', '/') -and
        [IO.Path]::GetFileName($resolved) -match '^UREngine-ReleaseTest-[a-f0-9]{32}$') 'Unsafe test cleanup path.'
    Remove-Item -LiteralPath $resolved -Recurse -Force
    Remove-Variable ureStudioReleaseTestCase -Scope Global
}
