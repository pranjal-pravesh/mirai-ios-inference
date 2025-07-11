# ChatAI-Pro

A native iOS chat application powered by [Mirai](https://trymirai.com) for on-device AI inference. Chat with powerful language models directly on your iPhone/iPad without internet connectivity.

## ✨ Features

- 🤖 **On-Device AI**: Run models locally using Mirai's optimized inference engine
- 📱 **Native iOS**: SwiftUI interface with smooth performance
- 🔄 **Model Management**: Download, switch, and delete models easily
- 📊 **Real-time Progress**: Visual download progress with percentage indicators
- ⚡ **Performance Options**: Memory offloading for better resource management
- 🎯 **Multiple Models**: Support for Qwen, Llama, DeepSeek, and more

## 📋 Requirements

- iOS 15.0+ / iPadOS 15.0+
- Xcode 14.0+
- Mirai API key from [trymirai.com](https://trymirai.com)
- ~2-4GB free storage (depending on models)

## 🚀 Setup

### 1. Get a Mirai API Key
1. Visit [trymirai.com](https://trymirai.com)
2. Sign up for an account
3. Navigate to your dashboard
4. Copy your API key

### 2. Configure the App
1. Open `ChatAI-Pro/LLMManager.swift`
2. Replace the empty API key with yours:
```swift
private let engine = UzuEngine(apiKey: "YOUR_API_KEY_HERE")
```

### 3. Build and Run
1. Open `ChatAI-Pro.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run the project

## 📱 How to Use

### First Launch
1. The app will automatically try to download the default model
2. Wait for the download to complete (progress shown in chat screen)
3. Once ready, the status indicator turns green ✅

### Managing Models

#### Access Settings
- Tap the **gear icon** ⚙️ in the top-right of the chat screen

#### Download New Models
1. In Settings, browse the **"Available Models"** section
2. Tap **"Download"** on any model you want
3. Watch the real-time progress bar
4. Models include:
   - **Qwen3 1.7B** (float16) - Recommended for most use cases
   - **Llama 3.2 1B** - Alternative high-quality model
   - **DeepSeek R1** - Specialized reasoning model

#### Switch Models
1. Download the model you want to use
2. Tap **"Use"** once download completes
3. The chat screen will show the new active model

#### Delete Models
- Tap **"Delete"** to remove downloaded models and free up storage

### Memory Optimization
- Toggle **"Memory Offloading"** in Settings to reduce RAM usage
- Useful for older devices or when running multiple apps

### Chatting
1. Ensure your model shows a **green status dot** ✅
2. Type your message in the text field
3. Tap **"Send"** or press return
4. Responses stream in real-time
5. Chat history is preserved during the session

## 🔧 Model Information

| Model | Size | Precision | Best For |
|-------|------|-----------|----------|
| Qwen3-1.7B-float16 | ~3.4GB | 16-bit | Highest quality responses |
| Qwen3-1.7B-int4 | ~1.2GB | 4-bit | Faster inference, smaller size |
| Llama-3.2-1B | ~2.0GB | 16-bit | General conversation |
| DeepSeek-R1 | ~3.0GB | 16-bit | Reasoning and analysis |

## 🎯 Tips

- **First Time**: Start with `Alibaba-Qwen3-1.7B-float16` for fastest download
- **Storage**: Delete unused models to save space
- **Performance**: Enable offloading on devices with <6GB RAM
- **Quality vs Speed**: Use int4 for speed, float16 for quality
- **Multiple Models**: Download several and switch based on your needs

## 🐛 Troubleshooting

### Download Issues
- Check internet connection
- Verify API key is valid
- Ensure sufficient storage space
- Try refreshing the model registry

### Model Not Loading
- Wait for download to complete (100%)
- Check the status indicator color
- Try restarting the app
- Verify model appears in Settings

### Performance Issues
- Enable memory offloading
- Close other apps
- Use int4 models instead of float16
- Restart the app

## 🔗 Links

- [Mirai Documentation](https://docs.trymirai.com)
- [Mirai Models](https://trymirai.com/models)
- [Swift Package](https://github.com/trymirai/uzu-swift)

## 📄 License

This project is for demonstration purposes. Please check Mirai's terms of service for commercial usage.

---

Built with ❤️ by Pranjal using SwiftUI and Mirai 