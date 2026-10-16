# UREngine

**Recover readable C# projects from Unity IL2CPP applications.**

[中文](./README-ch.md) · [Official website](https://www.ur-engine.com/en/) · [Download Studio](https://github.com/IIIImmmyyy/UREngine/releases/latest) · [Request a trial](https://www.ur-engine.com/en/trial/)

UREngine analyzes native code and metadata from Unity IL2CPP applications to recover C# code for navigation, cross-references, global search, and review. **UREngine Studio** is the Windows desktop client for preparing inputs, submitting decompilation tasks, tracking progress, downloading verified results, and browsing recovered code and assets.

This repository hosts product information, demonstrations, Studio downloads, and the release publishing script. The engine and Studio application source code are not published here.

## Download and get started

1. Download **UREngine-Studio-{version}-win-x64.zip** from [GitHub Releases](https://github.com/IIIImmmyyy/UREngine/releases/latest) or the [official website](https://www.ur-engine.com/en/#studio).
2. Extract the **entire ZIP** and launch **UREngine.Studio.exe**. Keep its accompanying files and the Assets directory together.
3. Request trial access on the website if needed, then activate Studio with your issued license.
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

## Publish the latest Studio release

Maintainers can sync the latest version already published on the official website:

    pwsh -File ./Publish-StudioRelease.ps1

The script downloads the official package, verifies its SHA-256 and embedded version, uploads the ZIP and checksum to a draft GitHub Release, and publishes only after checking both uploaded files. Repeating the command verifies an existing release or resumes an incomplete draft.

See [release publishing instructions](./RELEASING.md) for one-time GitHub CLI setup, local package uploads, and validation without publishing.

## Contact

- Website: [www.ur-engine.com](https://www.ur-engine.com/en/)
- Technical support: [support@ur-engine.com](mailto:support@ur-engine.com)
- Trial and business inquiries: [contact through the website](https://www.ur-engine.com/en/trial/)
- Related learning resource: [U3D Game Security Course](https://github.com/IIIImmmyyy/U3DGameCourse)

Use UREngine for software you own or are authorized to analyze. Unity is a trademark of Unity Technologies; UREngine is not affiliated with or endorsed by Unity Technologies.
