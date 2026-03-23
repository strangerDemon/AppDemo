# Edu Tools (智能教育与生活工具箱)

Edu Tools 是一款基于 Flutter 构建的跨平台移动应用，旨在利用 AI 视觉与语音技术，解决家庭教育和日常生活中的痛点。应用集成了四大核心功能，提供极简、直观的交互体验。

---

## ✨ 核心功能 (Features)

### 1. 英语单词听写 (AI Dictation)
- **拍照提取**：使用 Google ML Kit 扫描课本或词汇表，自动分离中英文。
- **智能播报**：自定义听写数量、语音播报间隔（秒）和每个单词的重复次数，利用 TTS 实现自动循环播报。
- **智能批改**：听写完成后，家长只需拍下孩子的默写本，App 即可自动对比并给出准确率评分。

### 2. 环境噪音监测与建议 (Noise Monitor)
- **实时仪表盘**：利用麦克风实时监测环境分贝（dB），表盘颜色随噪音等级动态变化（绿->蓝->橙->红）。
- **动态波形图**：直观展示过去 50 次采样的声波折线图。
- **AI 降噪分析**：模拟云端大模型，根据当前噪音分贝推测噪音源（如电钻声、人声），并生成对应的降噪建议。

### 3. 饮食热量视觉识别 (Food Calorie AI)
- **多模态估算**：拍照识别食物，模拟调用视觉大模型返回食物名称、估算重量、总卡路里及三大营养素比例。
- **手动微调**：允许用户修改估算重量，卡路里数据将按比例实时重算。
- **精美打卡分享**：生成带有环形数据图表的精美卡片，支持一键保存至本地相册或分享至微信/朋友圈。

### 4. 口算/方程式智能批改 (Math Grader)
- **全学段支持**：支持基础四则运算、带括号混合运算、分数小数，乃至基础的一元一次方程。
- **AR 级原图批改**：提取算式坐标，直接在用户拍摄的原图上绘制绿色的“✓”和红色的“✗”。
- **错题解析**：点击原图红叉区域，弹出包含**逐步列式解答过程**的详情面板，并支持加入错题本。

---

## 🛠 技术栈 (Tech Stack)

- **框架**: Flutter (Dart)
- **状态管理**: Provider (`provider`)
- **视觉/OCR**: Google ML Kit (`google_mlkit_text_recognition`)
- **语音/麦克风**: `flutter_tts`, `noise_meter`
- **数学解析**: `math_expressions`
- **图表与渲染**: `fl_chart`, CustomPaint
- **原生交互**: `image_picker`, `permission_handler`, `share_plus`, `gal`, `screenshot`

---

## 🚀 本地开发与运行指南 (Run Locally)

### 1. 环境准备
请确保你的电脑已安装以下环境：
- **Flutter SDK** (建议版本 3.19+)
- **Xcode** (用于 iOS 运行和打包)
- **Android Studio** (用于 Android 运行和打包，需配置好 Android SDK)

### 2. 获取依赖
在项目根目录（`dictation_app`）执行：
```bash
flutter pub get
```

### 3. 运行到真机 (推荐)
由于应用深度依赖**相机**和**麦克风**等原生硬件能力，**请勿在 Chrome Web 模式下调试核心功能**。
请用数据线连接你的 iPhone 或 Android 手机，并在终端运行：
```bash
flutter run
```

---

## 📦 打包与发布 (Build & Deploy)

### Android 打包 (APK)
在项目根目录执行以下命令，即可生成 Release 版本的 APK 安装包：
```bash
flutter build apk --release
```
生成的包位于：`build/app/outputs/flutter-apk/app-release.apk`。

### iOS 打包 (IPA)
由于苹果的安全限制，iOS 打包需要配置开发者签名：
1. 确保已安装 CocoaPods，在 `ios` 目录下执行 `pod install`。
2. 双击打开 `ios/Runner.xcworkspace` 进入 Xcode。
3. 在左侧选中 `Runner`，进入 `Signing & Capabilities` 标签页。
4. 勾选 `Automatically manage signing`，并在 `Team` 下拉菜单中选择你的 Apple 开发者账号。
5. 配置完成后，在项目根目录终端执行：
   ```bash
   flutter build ipa
   ```
6. 或者直接在 Xcode 顶部菜单栏点击 `Product` -> `Archive`，然后按照指引导出 IPA 文件。
