# Text-to-Speech App

A powerful macOS Text-to-Speech application with advanced voice controls, supporting both OpenAI and ElevenLabs TTS APIs.

## Features

### 🎙️ Multiple TTS Providers
- **OpenAI TTS**: High-quality speech synthesis with 6 built-in voices
- **ElevenLabs**: Premium AI voice synthesis with custom voices and emotions

### 🎛️ Advanced Voice Controls
- **Speed Control**: Adjust synthesis speed (0.25x to 4.0x for OpenAI, 0.5x to 2.0x for ElevenLabs)
- **Pitch Control**: Modify voice pitch (0.5x to 2.0x)
- **Volume Control**: Real-time volume adjustment (0% to 100%)
- **Playback Speed**: Independent playback speed control (0.5x to 2.0x)

### 😊 Voice Emotion Control
Support for 8 different emotional voice styles:
- **Neutral**: Standard, natural voice
- **Happy**: Upbeat and cheerful tone
- **Sad**: Melancholic and subdued
- **Excited**: Energetic and enthusiastic
- **Calm**: Peaceful and relaxed
- **Angry**: Intense and forceful
- **Whisper**: Soft and intimate
- **Dramatic**: Theatrical and expressive

*Note: Full emotion control is available with ElevenLabs. OpenAI voices use simulated emotion adjustments.*

### 🎵 Audio Playback Features
- **Play/Pause/Stop**: Full playback control
- **Progress Tracking**: Visual progress bar with time display
- **Seek Control**: Click to jump to any position in the audio
- **Real-time Audio Processing**: Apply volume and speed changes during playback

### ⚙️ User-Friendly Interface
- **Voice Controls Panel**: Dedicated interface for all audio settings
- **Provider Selection**: Easy switching between OpenAI and ElevenLabs
- **Voice Selection**: Browse and select from available voices
- **Settings Management**: Secure API key storage
- **Reset to Defaults**: Quick reset for all voice controls

## Installation

1. Clone this repository
2. Open `TextToSpeechApp.xcodeproj` in Xcode
3. Build and run the application

## Setup

### API Keys
You'll need API keys from one or both providers:

#### OpenAI Setup
1. Visit [OpenAI Platform](https://platform.openai.com)
2. Create an account and get your API key
3. In the app, go to Settings and enter your OpenAI API key

#### ElevenLabs Setup
1. Visit [ElevenLabs](https://elevenlabs.io)
2. Create an account and get your API key
3. In the app, go to Settings and enter your ElevenLabs API key

## Usage

### Basic Text-to-Speech
1. Select your preferred TTS provider (OpenAI or ElevenLabs)
2. Choose a voice from the dropdown
3. Enter your text in the text editor
4. Click "Generate Speech" to create audio
5. Use playback controls to play, pause, or stop

### Advanced Voice Controls
1. Click "Voice Controls" to open the controls panel
2. Adjust the following parameters:
   - **Speed**: Control how fast the text is spoken
   - **Pitch**: Adjust the voice pitch (higher/lower)
   - **Volume**: Set the audio volume level
   - **Playback Speed**: Control playback speed independently from synthesis speed
   - **Emotion**: Select from 8 emotional voice styles

### Voice Emotion Guide

| Emotion | Best Use Cases | ElevenLabs Settings |
|---------|---------------|-------------------|
| Neutral | General content, news, documentation | Balanced stability and similarity |
| Happy | Advertisements, children's content, celebrations | High similarity, moderate style |
| Sad | Dramatic readings, somber content | High stability, low similarity |
| Excited | Sports commentary, product launches | Low stability, high similarity, speaker boost |
| Calm | Meditation, relaxation, tutorials | Very high stability, low similarity |
| Angry | Dramatic performances, intense scenes | Moderate stability and similarity, style boost |
| Whisper | ASMR, intimate content, secrets | Very high stability, very low similarity |
| Dramatic | Theater, storytelling, presentations | Low stability, high style and similarity |

## Technical Features

### Audio Processing
- **AVAudioPlayer**: Native macOS audio playback
- **Real-time Controls**: Volume and speed adjustments during playback
- **Progress Tracking**: Accurate time-based progress indication

### Voice Synthesis
- **OpenAI Integration**: Uses the latest TTS-1 model with speed control
- **ElevenLabs Integration**: Advanced voice settings with emotion parameters
- **Quality Settings**: Optimized for clarity and naturalness

### Data Management
- **Secure Storage**: API keys stored in macOS Keychain
- **User Preferences**: Voice control settings persistence
- **Error Handling**: Comprehensive error reporting and recovery

## System Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)
- Internet connection (for TTS API calls)

## File Structure

```
TextToSpeechApp/
├── TextToSpeechApp.swift          # Main app entry point
├── ContentView.swift              # Main user interface
├── VoiceControlsView.swift        # Advanced voice controls panel
├── VoiceProvider.swift            # TTS provider models and voice controls
├── TTSService.swift               # TTS API integration
├── AudioPlayer.swift             # Audio playback with controls
├── SettingsView.swift             # API key configuration
└── TextToSpeechApp.entitlements   # App permissions
```

## API Usage Notes

### OpenAI TTS
- **Model**: TTS-1 (standard quality)
- **Voices**: alloy, echo, fable, onyx, nova, shimmer
- **Speed Range**: 0.25x to 4.0x
- **Pricing**: Pay per character generated

### ElevenLabs
- **Model**: eleven_monolingual_v1
- **Voices**: Custom and premium voices available
- **Speed Range**: 0.5x to 2.0x (via voice settings)
- **Emotion Support**: Full emotional voice control
- **Pricing**: Character-based with monthly limits

## Troubleshooting

### Common Issues

**"API key required" message**
- Ensure you've entered valid API keys in Settings
- Check that your API keys have sufficient credits/quota

**No voices available**
- Verify internet connection
- Check API key validity
- For ElevenLabs: Ensure your account has access to voices

**Audio not playing**
- Check system volume settings
- Verify app volume control isn't set to 0%
- Ensure no other apps are blocking audio

**Generation takes too long**
- Large text blocks take more time to process
- ElevenLabs may have longer processing times for emotional voices
- Check your internet connection speed

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is available under the MIT License. See LICENSE file for details.

## Credits

- Built with SwiftUI and AVFoundation
- Powered by OpenAI TTS and ElevenLabs APIs
- Voice emotion presets optimized for natural speech patterns

---

*Enjoy creating natural, expressive speech with advanced voice controls!*