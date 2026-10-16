# UREngine

**Recover readable C# projects from Unity IL2CPP applications.**

[中文](./README-ch.md) · [Official website](https://www.ur-engine.com/en/) · [Download Studio](https://github.com/IIIImmmyyy/UREngine/releases/latest) · [Apply for beta](https://www.ur-engine.com/en/trial/)

UREngine analyzes native code and metadata from Unity IL2CPP applications to recover C# code for navigation, cross-references, global search, and review. **UREngine Studio** is the Windows desktop client for preparing inputs, submitting decompilation tasks, tracking progress, downloading verified results, and browsing recovered code and assets.

This repository hosts product information, demonstrations, and Studio downloads. The engine and Studio application source code are not published here.

**UREngine is currently in closed beta.** Apply on the website with your project details and analysis needs. Applications are reviewed before access is granted; approved applicants receive activation instructions by email.

## Download and get started

1. Download **UREngine-Studio-{version}-win-x64.zip** from [GitHub Releases](https://github.com/IIIImmmyyy/UREngine/releases/latest) or the [official website](https://www.ur-engine.com/en/#studio).
2. Extract the **entire ZIP** and launch **UREngine.Studio.exe**. Keep its accompanying files and the Assets directory together.
3. Apply for the closed beta on the website. Once approved, activate Studio with the license provided by email.
4. Select a supported package, choose the assemblies to analyze, submit the task, and open the recovered project when processing finishes.

The release is a **Windows x64 portable package**. Decompilation requires activation and network access. Studio uses Microsoft Edge WebView2; VS Code is recommended for browsing generated C# projects.

Download the Studio ZIP under **Assets** on the release page. GitHub's automatically generated **Source code** archives contain this documentation repository, not the Studio application. Each Studio ZIP has a SHA-256 checksum alongside it.

[User guide](https://www.ur-engine.com/en/guide/) · [FAQ](https://www.ur-engine.com/en/faq/) · [Support scope](https://www.ur-engine.com/en/support/) · [Changelog](https://www.ur-engine.com/en/changelog/)

## Current scope

| Item | Current availability |
| --- | --- |
| Studio desktop client | Windows x64; Chinese and English UI |
| Application input | Unity 2022.x Android IL2CPP, ARM64-v8a; APK, XAPK and APKS input in Studio |
| Code recovery | Readable C# projects, instantiated generic calls, coroutines and async/await state machines |
| Code and assets | Open recovered projects in VS Code; browse assets through the bundled asset browser |
| Generic method declarations | Methods that declare their own type parameters, such as `Method<T>`, are not yet supported |
| iOS IPA | Planned |
| Unity project export | Not enabled in the public Studio release; contact us for enterprise requirements |

Recovery results depend on the input and supported features. Use your own project to evaluate the output; see the website for the current support scope.

## Demo

The video demonstrates the APK-to-Unity-project recovery workflow. Unity project export shown in the demo is subject to the availability described above.

https://github.com/user-attachments/assets/b4409379-0794-4224-8802-2f023e41df4a

[Code recovery examples](./UREngine-description.md)

<details>
<summary>Earlier development previews</summary>

![UREngine development preview](./source/URengine-main.png)
![Recovered code comparison](./source/UREngine-review-ida.png)

</details>

## Contact

- Website: [www.ur-engine.com](https://www.ur-engine.com/en/)
- Technical support: [support@ur-engine.com](mailto:support@ur-engine.com)
- Closed beta: [apply on the website](https://www.ur-engine.com/en/trial/)
- Business inquiries: [business@ur-engine.com](mailto:business@ur-engine.com)
- Related learning resource: [U3D Game Security Course](https://github.com/IIIImmmyyy/U3DGameCourse)

Use UREngine for software you own or are authorized to analyze. Unity is a trademark of Unity Technologies; UREngine is not affiliated with or endorsed by Unity Technologies.
