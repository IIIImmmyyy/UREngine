# UREngine

**从 Unity IL2CPP 应用，恢复可读、可浏览的 C# 工程。**

[English](./README.md) · [官方网站](https://www.ur-engine.com/) · [下载 Studio](https://github.com/IIIImmmyyy/UREngine/releases/latest) · [申请试用](https://www.ur-engine.com/trial/)

UREngine 分析 Unity IL2CPP 应用中的原生代码与元数据，恢复便于交叉引用、全局搜索和审阅的 C# 工程。**UREngine Studio** 是配套的 Windows 桌面客户端，用于准备输入、提交反编译任务、查看进度、下载并校验结果，以及浏览恢复后的代码与资源。

本仓库提供产品介绍、演示资料、Studio 下载和发布脚本。引擎与 Studio 应用源代码未在此仓库公开。

## 下载与开始使用

1. 从 [GitHub Releases](https://github.com/IIIImmmyyy/UREngine/releases/latest) 或 [官网](https://www.ur-engine.com/#studio) 下载 **UREngine-Studio-<版本号>-win-x64.zip**。
2. **完整解压 ZIP**，运行 **UREngine.Studio.exe**。请保留附带文件和 Assets 目录。
3. 如需试用，在官网提交申请；获得授权后，在 Studio 中激活。
4. 选择支持的安装包和待分析程序集，提交任务；处理完成后打开恢复的工程。

当前提供 **Windows x64 便携版**。反编译需要激活与联网。Studio 使用 Microsoft Edge WebView2；推荐安装 VS Code 浏览生成的 C# 工程。

请下载 Release 页面 **Assets** 下的 Studio ZIP。GitHub 自动生成的 **Source code** 压缩包仅包含本介绍仓库，并非 Studio 应用。每个安装包均附带 SHA-256 校验文件。

[使用指南](https://www.ur-engine.com/guide/) · [常见问题](https://www.ur-engine.com/faq/) · [支持范围](https://www.ur-engine.com/support/) · [更新日志](https://www.ur-engine.com/changelog/)

## 当前支持范围

| 项目 | 当前状态 |
| --- | --- |
| Studio 桌面客户端 | Windows x64，中英文界面 |
| 应用输入 | Unity 2022.x、Android IL2CPP、ARM64-v8a；Studio 支持选择 APK、XAPK、APKS |
| 代码还原 | 可读的 C# 工程，已实例化泛型调用、协程和 async/await 状态机 |
| 代码与资源浏览 | 在 VS Code 中打开恢复的工程，通过附带的资源浏览器查看资源 |
| 泛型方法声明 | 暂不支持方法自身声明类型参数的形式，例如 `Method<T>` |
| iOS IPA | 计划支持 |
| Unity 工程导出 | 公开版 Studio 暂未开放；企业需求请联系咨询 |

实际恢复效果取决于输入与支持范围，建议使用自己的项目验证。最新能力说明以官网为准。

## 演示视频

视频演示从 APK 到 Unity 工程的恢复流程。视频中的 Unity 工程导出能力适用上表所述的开放范围。

https://github.com/user-attachments/assets/b4409379-0794-4224-8802-2f023e41df4a

[查看代码还原示例](./UREngine-description.md)

<details>
<summary>早期开发预览</summary>

![UREngine 开发预览](./source/URengine-main.png)
![代码还原对比](./source/UREngine-review-ida.png)

</details>

## 发布最新版 Studio

维护者可以用一条命令，将官网已经发布的最新版同步到 GitHub：

    pwsh -File ./Publish-StudioRelease.ps1

脚本自动下载官网安装包，校验 SHA-256 与包内版本，将 ZIP 和校验文件上传至 GitHub Release 草稿，确认上传内容一致后正式发布。重复执行会校验已有版本，或继续完成未发布的草稿。

首次 GitHub CLI 登录、本地安装包上传、只校验不发布等用法见 [发布说明](./RELEASING.md)。

## 联系方式

- 官网：[www.ur-engine.com](https://www.ur-engine.com/)
- 技术支持：[support@ur-engine.com](mailto:support@ur-engine.com)
- 试用与商务咨询：[通过官网联系](https://www.ur-engine.com/trial/)
- 相关学习资源：[Android U3D 手游安全课程](https://github.com/IIIImmmyyy/U3DGameCourse)

请仅分析自己拥有或已获授权的软件。Unity 是 Unity Technologies 的商标；UREngine 与其无隶属或背书关系。
