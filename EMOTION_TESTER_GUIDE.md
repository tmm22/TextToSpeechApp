# Emotion Tester Guide

## Overview

The EmotionTester is an automated testing tool for the TextToSpeechApp that systematically tests all 8 voice emotions with any selected voice provider. It provides comprehensive testing, logging, and audio file generation for quality assurance and debugging purposes.

## Features

### Automated Testing
- Tests all 8 emotions: `neutral`, `happy`, `sad`, `excited`, `calm`, `angry`, `whisper`, `dramatic`
- Uses `VoiceEmotion.allCases` to ensure all emotions are tested
- Sequential testing with progress tracking
- Standardized test phrase: "This is a test of the [emotion] voice emotion. The quick brown fox jumps over the lazy dog."

### Parameter Verification
- Logs ElevenLabs parameters for each emotion:
  - Stability
  - Similarity Boost
  - Style
  - Speaker Boost
- Validates parameter ranges (0.0-1.0 for most parameters)

### Audio File Generation
- Saves audio output for each emotion as MP3 files
- Files named by emotion: `neutral_test_elevenlabs.mp3`, `happy_test_openai.mp3`, etc.
- Stored in `~/Documents/EmotionTests/` directory
- Automatic directory creation if it doesn't exist

### Comprehensive Logging
- Real-time progress updates
- Parameter logging for each emotion
- Success/failure status for each test
- Error messages with detailed descriptions
- Timestamped log entries
- Test duration tracking

### User Interface
- Simple, intuitive interface integrated into the main app
- Provider and voice selection
- Real-time progress bar
- Test control buttons (Start/Stop)
- Results summary display
- Detailed results viewer with export functionality

## How to Access

1. Launch the TextToSpeechApp
2. Click the **"Emotion Tester"** button in the top toolbar
3. The EmotionTester window will open as a sheet overlay

## How to Use

### Step 1: Configure Test Settings
1. **Select Provider**: Choose between ElevenLabs or OpenAI
2. **Select Voice**: Pick a voice from the available options
   - For ElevenLabs: Requires valid API key and loads available voices
   - For OpenAI: Shows built-in voices (Alloy, Echo, Fable, Onyx, Nova, Shimmer)

### Step 2: Run Tests
1. Click **"Run Emotion Tests"** to start the automated testing
2. Monitor progress in real-time:
   - Current emotion being tested
   - Progress percentage
   - Live log messages

### Step 3: Review Results
1. **Test Summary**: Shows completion status and any failures
2. **View Results**: Click to see detailed results including:
   - Success/failure status for each emotion
   - Test duration for each emotion
   - ElevenLabs parameters used (if applicable)
   - Error messages for failed tests
   - Complete log history

### Step 4: Export Results
1. In the results view, click **"Export Results"**
2. Results are copied to clipboard in formatted text
3. Can be pasted into documents, emails, or bug reports

## API Key Requirements

### ElevenLabs Testing
- Requires valid ElevenLabs API key
- Set in Settings before running tests
- Tests all emotion-specific parameters:
  - Neutral: Stability=0.5, SimilarityBoost=0.5, Style=0.0, SpeakerBoost=false
  - Happy: Stability=0.3, SimilarityBoost=0.8, Style=0.3, SpeakerBoost=true
  - Sad: Stability=0.8, SimilarityBoost=0.3, Style=0.0, SpeakerBoost=false
  - Excited: Stability=0.2, SimilarityBoost=0.9, Style=0.5, SpeakerBoost=true
  - Calm: Stability=0.9, SimilarityBoost=0.2, Style=0.0, SpeakerBoost=false
  - Angry: Stability=0.4, SimilarityBoost=0.7, Style=0.4, SpeakerBoost=true
  - Whisper: Stability=0.9, SimilarityBoost=0.1, Style=0.0, SpeakerBoost=false
  - Dramatic: Stability=0.3, SimilarityBoost=0.6, Style=0.6, SpeakerBoost=true

### OpenAI Testing
- Requires valid OpenAI API key
- Set in Settings before running tests
- Tests speed parameter (emotions don't affect OpenAI TTS parameters)

## Output Files

### Audio Files Location
```
~/Documents/EmotionTests/
├── neutral_test_elevenlabs.mp3
├── happy_test_elevenlabs.mp3
├── sad_test_elevenlabs.mp3
├── excited_test_elevenlabs.mp3
├── calm_test_elevenlabs.mp3
├── angry_test_elevenlabs.mp3
├── whisper_test_elevenlabs.mp3
└── dramatic_test_elevenlabs.mp3
```

### File Naming Convention
- Format: `{emotion}_test_{provider}.mp3`
- Examples:
  - `happy_test_elevenlabs.mp3`
  - `neutral_test_openai.mp3`

## Error Handling

### Common Issues and Solutions

1. **"API key not set"**
   - Solution: Set the appropriate API key in Settings

2. **"No voices available"**
   - For ElevenLabs: Check API key and internet connection
   - For OpenAI: Should not occur (built-in voices)

3. **Network errors**
   - Check internet connection
   - Verify API key validity
   - Check API service status

4. **File save errors**
   - Ensure write permissions to Documents folder
   - Check available disk space

### Test Interruption
- Click **"Stop Tests"** to halt testing at any time
- Partial results are preserved
- Can restart testing from the beginning

## Integration with Existing App

### Code Architecture
- `EmotionTester.swift`: Main testing logic and UI
- Integrated with existing `TTSService` and `APIKeyManager`
- Uses existing `VoiceEmotion` enum and settings
- Leverages current app's network and audio handling

### No Breaking Changes
- Fully backward compatible
- Existing functionality unchanged
- Optional feature that can be ignored if not needed

## Use Cases

### Quality Assurance
- Verify all emotions work correctly
- Compare audio output across different voices
- Validate parameter configurations

### Development Testing
- Quick regression testing after code changes
- Batch testing of new voices or providers
- Parameter tuning and validation

### Debugging
- Isolate emotion-specific issues
- Generate consistent test cases
- Log detailed error information

### Documentation
- Generate audio samples for documentation
- Create voice comparison materials
- Demonstrate emotion capabilities

## Technical Details

### Test Execution Flow
1. Validate prerequisites (API keys, voice selection)
2. Initialize test environment
3. For each emotion in `VoiceEmotion.allCases`:
   - Set emotion parameters
   - Generate speech with test phrase
   - Save audio file
   - Log results
   - Update progress
4. Generate final summary

### Parameter Verification
- Validates ElevenLabs parameters are within expected ranges
- Logs actual parameters sent to API
- Compares expected vs actual configurations

### Error Recovery
- Individual emotion failures don't stop entire test
- Detailed error logging for troubleshooting
- Graceful handling of network timeouts

## Future Enhancements

Potential improvements for future versions:
- Custom test phrases
- Batch testing multiple voices
- Audio quality analysis
- Performance benchmarking
- Automated regression testing
- Integration with CI/CD pipelines

## Support

For issues or questions about the EmotionTester:
1. Check the log messages for specific error details
2. Verify API key configuration in Settings
3. Ensure stable internet connection
4. Review this guide for common solutions