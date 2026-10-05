# bytelab · iOS 客户端工程

加载 https://bytelab.cc.cd/ 的原生 WKWebView 壳应用（SwiftUI）。

## 为什么没有直接给你 .ipa

- 编 .ipa 必须用苹果 Xcode，**只能在 macOS 上**（这台 Windows 机器编不了 iOS 包）。
- 即使编出来，**没有 Apple 开发者账号（$99/年）签名，iPhone 不会信任安装**：要么弹"未受信任的开发者"提示，要么用免费 Apple ID 走 sideload，**每 7 天过期需重签**。

所以在苹果侧，官方免信任、免账号的方案仍是 **PWA**：iPhone Safari 打开站点 → 分享 →「添加到主屏幕」。
本工程是给**确实要独立 App** 时用的（需要你有 Mac，或用 GitHub Actions 的 macOS 构建机）。

## 在 Mac 上构建

1. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)（`brew install xcodegen`）。
2. 在工程根目录（`project.yml` 所在处）执行 `xcodegen generate`，生成 `bytelab.xcodeproj`。
3. 打开 `bytelab.xcodeproj`，在 Signing 里选你自己的 Apple 开发者 Team，`Product → Archive`。

## 用 GitHub Actions 出 .ipa（无需本机 Mac）

仓库结构：
```
根/
  bytelab-ios/            <- 本工程
  .github/workflows/ios-build.yml
```
推送到 GitHub，手动触发 `build-bytelab-ios`，会跑 macOS 构建机编出 `.ipa` 产物。
> 工作流默认 **CODE_SIGNING_ALLOWED=NO**（不签名）。要产出能装的 .ipa，需要你在仓库 Secrets 里配好 Apple 开发者账号（`APPLE_ID` / `APPLE_APP_SPECIFIC_PASSWORD` / `TEAM_ID`），并把工作流改成签名 + export。免费账号签名 7 天过期。

## 工程结构

```
bytelab-ios/
  project.yml                     XcodeGen 清单
  bytelab/
    bytelabApp.swift              SwiftUI + WKWebView 壳
    Info.plist
    Assets.xcassets/
      AppIcon.appiconset/         1024 主图标（琥珀播放三角）
  .github/workflows/ios-build.yml CI 出 .ipa
```
