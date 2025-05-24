# TextToSpeechApp - Modern & Streamlined

A beautifully designed, modern Text-to-Speech application for macOS with voice controls, emotion testing, and keyboard shortcuts. Built with SwiftUI and focused on simplicity and user experience.

## ✨ Features

### 🎯 **Modern, Streamlined Interface**
- **Minimal Design**: Clean, focused UI with reduced visual clutter
- **Floating Controls**: Context-aware controls that appear when needed
- **Glass Morphism**: Ultra-thin material backgrounds for modern aesthetics
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Layout**: Adapts beautifully to different window sizes

### 🎤 **Voice Providers**
- **OpenAI TTS**: High-quality voices with speed control
- **ElevenLabs**: Premium AI voices with emotion control
- **Easy Switching**: Simple pill-style provider selection

### 🎭 **Emotion System**
- **8 Emotion Presets**: Neutral, Happy, Sad, Excited, Calm, Angry, Whisper, Dramatic
- **Automatic Testing**: Test all emotions with one click
- **Parameter Visualization**: See stability, similarity boost, and style settings
- **Audio Export**: Save emotion test results as MP3 files

### ⌨️ **Keyboard Shortcuts**
- **⌘+V**: Copy text from clipboard
- **⌘+Return**: Generate speech from current text
- **⌘+Shift+V**: Copy from clipboard and speak immediately
- **Global Shortcuts**: Work from any application

### 🎛️ **Voice Controls**
- **Speed Control**: 0.25x to 4.0x playback speed
- **Pitch Adjustment**: Fine-tune voice pitch
- **Volume Control**: Precise audio level control
- **Real-time Preview**: Hear changes instantly

### 🌙 **Theme System**
- **Dark Mode**: Beautiful dark theme (default)
- **Light Mode**: Clean light theme
- **System Sync**: Automatically follows system preferences
- **Gradient Backgrounds**: Subtle gradients enhance the visual experience

## 🚀 Quick Start

1. **Launch the App**: Double-click TextToSpeechApp.app
2. **Set API Keys**: Click the menu (•••) → Settings → Add your API keys
3. **Select Provider**: Choose OpenAI or ElevenLabs
4. **Pick a Voice**: Select from available voices
5. **Enter Text**: Type or paste text in the input area
6. **Generate**: Click "Generate Speech" or press ⌘+Return

## 🎮 Interface Guide

### Main Interface
```
┌─────────────────────────────────────┐
│ TTS                            •••  │ ← Minimal header with menu
├─────────────────────────────────────┤
│                                     │
│     [OpenAI] [ElevenLabs]          │ ← Provider pills
│                                     │
│     [Select Voice ▼]               │ ← Voice dropdown
│                                     │
│     ┌─────────────────────────────┐ │
│     │ Enter text to speak...      │ │ ← Text input area
│     │                             │ │
│     └─────────────────────────────┘ │
│                                     │
│        [Generate Speech]            │ ← Main action button
│                                     │
└─────────────────────────────────────┘
```

### Quick Actions Menu (•••)
- **Voice Controls**: Adjust speed, pitch, volume, emotion
- **Emotion Tester**: Test all voice emotions automatically
- **Settings**: Configure API keys and preferences
- **GitHub**: Contribute to the project

### Audio Controls (appears when playing)
```
┌─────────────────────────────────────┐
│ 0:15 ████████░░░░░░░░░░░░░░░ 1:23   │ ← Progress bar
│                                     │
│        ⏸️  ⏹️                       │ ← Playback controls
└─────────────────────────────────────┘
```

## 🔧 Advanced Features

### Emotion Testing
1. Open Quick Actions → Emotion Tester
2. Select provider and voice
3. Click "Run Emotion Tests"
4. Listen to each emotion automatically
5. Export results or view detailed logs

### Voice Controls
1. Open Quick Actions → Voice Controls
2. Adjust sliders for speed, pitch, volume
3. Select emotion preset
4. Changes apply to next generation

### Keyboard Shortcuts
- All shortcuts work globally (from any app)
- Shortcuts are customizable in Settings
- Visual feedback shows when shortcuts are triggered

## 🛠️ Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **URLSession**: Network requests for TTS APIs
- **AVFoundation**: Audio playback and control

### Performance
- **Lazy Loading**: UI elements load on demand
- **Memory Efficient**: Optimized for low memory usage
- **Background Processing**: Network requests don't block UI
- **Caching**: Smart caching of voice lists and settings

### Security
- **Sandboxed**: App runs in secure sandbox environment
- **Keychain Storage**: API keys stored securely
- **Network Permissions**: Only required network access
- **No Data Collection**: Your text never leaves your device (except to TTS APIs)

## 🎨 Design Philosophy

### Simplicity First
- **Minimal UI**: Only essential elements visible
- **Progressive Disclosure**: Advanced features hidden until needed
- **Clear Hierarchy**: Visual hierarchy guides user attention
- **Consistent Patterns**: Similar actions work the same way

### Modern Aesthetics
- **Glass Morphism**: Translucent materials create depth
- **Rounded Corners**: Soft, friendly interface elements
- **Subtle Shadows**: Depth without distraction
- **Smooth Animations**: 60fps transitions throughout

### Accessibility
- **High Contrast**: Clear visual distinction between elements
- **Large Touch Targets**: Easy to click/tap interface elements
- **Keyboard Navigation**: Full keyboard accessibility
- **Screen Reader Support**: VoiceOver compatible

## 🔑 API Setup

### OpenAI Setup
1. Visit [OpenAI Platform](https://platform.openai.com)
2. Create account and generate API key
3. Add key in Settings → OpenAI API Key
4. Supports voices: Alloy, Echo, Fable, Onyx, Nova, Shimmer

### ElevenLabs Setup
1. Visit [ElevenLabs](https://elevenlabs.io)
2. Create account and get API key
3. Add key in Settings → ElevenLabs API Key
4. Access to premium AI voices with emotion control

## 🚀 Contributing

We welcome contributions! Here's how to get involved:

### Development Setup
```bash
git clone https://github.com/tmm22/TextToSpeechApp.git
cd TextToSpeechApp
open TextToSpeechApp.xcodeproj
```

### Areas for Contribution
- **New Voice Providers**: Add support for more TTS services
- **UI Improvements**: Enhance the interface design
- **Performance**: Optimize for better performance
- **Features**: Add new functionality
- **Documentation**: Improve guides and documentation

### Code Style
- Follow Swift conventions
- Use SwiftUI best practices
- Comment complex logic
- Write descriptive commit messages

## 📝 Changelog

### v2.0.0 - Modern UI Overhaul
- ✨ Complete UI redesign with modern aesthetics
- 🎯 Streamlined interface with floating controls
- 🎨 Glass morphism design language
- ⚡ Improved performance and responsiveness
- 🎭 Enhanced emotion testing system
- ⌨️ Better keyboard shortcuts integration

### v1.0.0 - Initial Release
- 🎤 OpenAI and ElevenLabs TTS support
- 🎛️ Voice controls and emotion presets
- ⌨️ Keyboard shortcuts
- 🌙 Dark/Light theme support

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- **OpenAI** for excellent TTS API
- **ElevenLabs** for premium AI voices
- **Apple** for SwiftUI framework
- **Contributors** who help improve the app

---

**Made with ❤️ for the macOS community**

*Simplicity is the ultimate sophistication.*