# Changelog

All notable changes to the TextToSpeechApp project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-05-24

### Fixed
- **Build Issues**: Added missing AppKit import for NSWorkspace functionality
  - Resolves compilation errors when using NSWorkspace.shared.open()
  - Ensures GitHub contribution button works correctly
  - Fixes build failures on clean environments

### Added
- **Dark Mode Support**: Added comprehensive dark mode theming throughout the application
  - Theme selection in Settings (Light, Dark, System)
  - Improved UI contrast and readability in dark environments
  - Theme preference is saved between app launches
  - Consistent styling across all app views

- **Contribute on GitHub Button**: Added a prominent "Contribute on GitHub" button in the main interface header
  - Clickable heart icon with "Contribute on GitHub" text
  - Opens the project's GitHub repository in the default browser
  - Includes helpful tooltip text
  - Styled with blue color to indicate it's a clickable link

### Enhanced
- **User Interface**: Improved header layout with better organization of action buttons
- **Community Engagement**: Made it easier for users to find and contribute to the project
- **Accessibility**: Enhanced text contrast and readability in both light and dark modes

## [1.0.0] - 2025-01-24

### 🎉 Initial Release - Advanced macOS Text-to-Speech Application

#### Added
- **Dual TTS Provider Support**
  - OpenAI TTS integration with 6 premium voices (alloy, echo, fable, onyx, nova, shimmer)
  - ElevenLabs integration with custom voice support and premium AI voices
  - Seamless provider switching in the user interface

- **Advanced Voice Controls**
  - Speed control: 0.25x to 4.0x for OpenAI, 0.5x to 2.0x for ElevenLabs
  - Pitch adjustment: 0.5x to 2.0x range
  - Volume control: 0% to 100% with real-time adjustment
  - Independent playback speed control: 0.5x to 2.0x
  - 8 emotional voice styles: Neutral, Happy, Sad, Excited, Calm, Angry, Whisper, Dramatic

- **Professional Audio Playback**
  - Play/Pause/Stop controls with visual feedback
  - Progress tracking with interactive timeline
  - Seek functionality - click anywhere on timeline to jump to position
  - Real-time audio processing during playback
  - Current time and total duration display

- **User Experience Features**
  - Native macOS SwiftUI interface with modern design
  - Dedicated Voice Controls panel with organized settings
  - Secure API key storage in macOS Keychain
  - One-click reset to defaults for all voice controls
  - Comprehensive error handling and user feedback
  - Provider-specific voice selection with automatic loading

- **Technical Implementation**
  - Built with SwiftUI for modern macOS applications
  - AVFoundation integration for professional audio playback
  - Secure credential management with Keychain Services
  - Real-time audio processing and effects
  - Modular architecture with separated concerns
  - Comprehensive error handling and recovery

#### Technical Details
- **Minimum Requirements**: macOS 13.0 or later
- **Dependencies**: Native SwiftUI, AVFoundation, Foundation
- **API Integrations**: OpenAI TTS-1 model, ElevenLabs eleven_monolingual_v1
- **Security**: Keychain storage for API credentials
- **Audio**: Real-time processing with AVAudioPlayer

#### File Structure
```
TextToSpeechApp/
├── TextToSpeechApp.swift          # Main app entry point
├── ContentView.swift              # Main user interface
├── VoiceControlsView.swift        # Advanced voice controls panel
├── VoiceProvider.swift            # TTS provider models and voice controls
├── TTSService.swift               # TTS API integration service
├── AudioPlayer.swift              # Audio playback with advanced controls
├── SettingsView.swift             # API key configuration interface
├── ThemeManager.swift             # Dark mode and theme management
└── TextToSpeechApp.entitlements   # App permissions and capabilities
```

#### Known Limitations
- Emotion control fully supported only with ElevenLabs (OpenAI uses simulated adjustments)
- Internet connection required for all TTS operations
- API rate limits depend on provider subscription plans

#### Future Enhancements
- Offline TTS support
- Custom voice training integration
- Batch processing for multiple texts
- Audio export in various formats
- Voice cloning capabilities