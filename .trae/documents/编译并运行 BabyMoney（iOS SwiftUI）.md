## 环境要求
- 安装 `Xcode 16.3+`（包含 iOS 18 模拟器运行时）。
- 如果本机暂未安装 iOS 18.4 运行时，可在运行前将部署版本调整为本机已有版本（见“常见问题”）。

## 代码结构要点
- 入口：`@main` 应用在 `BabyMoney/BabyMoneyApp.swift:10`，首屏为 `ContentView()`（`BabyMoney/ContentView.swift:3`）。
- 工程：`BabyMoney.xcodeproj`，目标名：`BabyMoney`（`BabyMoney.xcodeproj/project.pbxproj:51-72`）。
- Bundle ID：`elon.BabyMoney`（`BabyMoney.xcodeproj/project.pbxproj:271`，Debug；Release 于 `:311`）。
- iOS 部署版本：`IPHONEOS_DEPLOYMENT_TARGET = 18.4`（`BabyMoney.xcodeproj/project.pbxproj:266,306`）。
- 无第三方依赖（无 `Package.swift`/`Podfile`）。

## 使用 Xcode 图形界面运行（推荐）
- 打开 `BabyMoney.xcodeproj`。
- 左上角选择 Scheme：若“BabyMoney”不可选，则新建 Scheme 绑定目标 `BabyMoney`。
- 选择模拟器设备：如 `iPhone 16` 或任意本机已安装的 iOS 设备。
- 点击运行（▶）。Xcode 将自动构建并在模拟器中启动应用。

## 使用命令行运行（无需修改工程）
- 构建到 iOS 模拟器（若未共享 Scheme，可用 `-target`）：
  - `xcodebuild -project BabyMoney.xcodeproj -target BabyMoney -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath build clean build`
- 启动模拟器并安装/运行：
  - 打开模拟器：`open -a Simulator`
  - 安装产物：
    - `APP_PATH=$(find build/Build/Products/Debug-iphonesimulator -name BabyMoney.app -maxdepth 1)`
    - `xcrun simctl install booted "$APP_PATH"`
  - 启动应用：`xcrun simctl launch booted elon.BabyMoney`
- 说明：如果存在共享 Scheme，可将上面的构建改为 `-scheme BabyMoney`。

## 常见问题与处理
- iOS 部署版本不匹配（如本机仅有 iOS 18.1 或 17.x）：
  - 方案 A（图形界面）：在 Xcode 的 `Build Settings` 中将 `iOS Deployment Target` 下调到本机已安装的运行时版本。
  - 方案 B（命令行临时选择设备）：将 `-destination` 的设备名称换成本机确实存在的模拟器设备（用 `xcrun simctl list devices` 查看）。
- Scheme 不共享导致命令行构建失败：
  - 使用 `-target BabyMoney` 代替 `-scheme`，或在 Xcode 中将 Scheme 设为 Shared。
- 真机运行需要签名：
  - Debug 下模拟器无需签名；真机需在 Xcode 选择自己的 `Team` 并连接设备。

## 运行后验证
- 启动后首屏显示“宝宝存钱罐”，两个用户卡片“姐姐”“妹妹”（参见 `BabyMoney/ContentView.swift:13,22,31`）。
- 点击用户卡片进入 Dashboard（`BabyMoney/DashboardView.swift`）。
- 若能正常导航与显示即为编译运行成功。