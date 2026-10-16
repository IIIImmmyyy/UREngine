# Studio 发布到 GitHub / Publishing Studio to GitHub

运行本仓库的 Publish-StudioRelease.ps1，可将**官网已发布的最新版**同步到 IIIImmmyyy/UREngine 的 GitHub Releases。脚本不构建 Studio，也不修改官网发布状态。

The script mirrors the latest official website release to GitHub. Build and publish Studio through the normal production workflow first.

## 首次配置 / One-time setup

需要 PowerShell 7 和 [GitHub CLI](https://cli.github.com/)，并使用对该仓库有写入权限的 GitHub 账号：

    winget install --id GitHub.cli -e
    gh auth login --hostname github.com
    gh auth status --hostname github.com

在你自己的终端完成登录，不要把 token 写入脚本或提交到仓库。GitHub 网页登录和 CLI 登录相互独立。

## 一条命令同步最新版 / Sync the latest version

在本仓库目录执行：

    pwsh -File ./Publish-StudioRelease.ps1

无需填写版本号。脚本读取 https://www.ur-engine.com/downloads/studio/latest.json，下载并验证官网安装包，生成中英文发布说明，上传 ZIP 和 .sha256 文件，再将对应的 studio-v<版本号> Release 发布为 Latest。

## 使用已有本地安装包 / Use a local package

    pwsh -File ./Publish-StudioRelease.ps1 -PackagePath "E:\RiderDemo2\UREngine.Platform\artifacts\UREngine-Studio-1.0.2-win-x64.zip"

请替换为当前版本的路径。本地文件的名称、大小、SHA-256 和包内版本必须与官网最新发布清单一致；这可以避免把调试包或旧包误上传。

## 只检查，不发布 / Validate without publishing

    pwsh -File ./Publish-StudioRelease.ps1 -DryRun
    pwsh -File ./Publish-StudioRelease.ps1 -PackagePath "C:\Releases\UREngine-Studio-1.0.2-win-x64.zip" -DryRun

此模式不需要 GitHub CLI 或 GitHub 登录，也不会更改 GitHub。未提供本地文件时仍会下载官网安装包完成校验。

## 重复执行与失败恢复 / Retry behavior

- ZIP 或校验文件上传失败时，Release 保持草稿；重新运行会继续上传缺少的文件。
- 已存在且内容一致的附件会被跳过；已发布且校验通过的版本不会重复发布。
- 同名附件大小或 SHA-256 不同，或已发布版本缺少附件时，脚本停止并报告问题。请在 GitHub 检查该版本，或使用新的 Studio 版本号。
- GitHub API 返回的附件摘要必须与本地 SHA-256 一致，检查通过后才会发布。
- 临时下载文件与说明会自动清理；传入的本地安装包不会被修改或删除。
- 新建版本使用该文档仓库默认分支作为标签目标；该标签不表示私有引擎源码的提交。

## 脚本自检 / Offline self-check

    pwsh -File ./Test-PublishStudioRelease.ps1

自检使用临时 ZIP 和模拟的官网、GitHub 响应，覆盖校验失败、首次发布、上传失败后续传、已发布版本重复执行及附件不一致等情况，不连接 GitHub、不发布版本。
