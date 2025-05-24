# Keyboard Shortcuts Guide

This guide explains the new keyboard shortcuts added to the Text-to-Speech application for enhanced productivity.

## Available Shortcuts

### 1. Copy Text from Clipboard and Speak
- **Shortcut**: `⌘⇧S` (Command + Shift + S)
- **Function**: Automatically copies text from the system clipboard into the text input field and immediately generates speech
- **Use Case**: Perfect for quickly converting copied text from other applications into speech

### 2. Copy Text from Clipboard
- **Shortcut**: `⌘⇧C` (Command + Shift + C)
- **Function**: Copies text from the system clipboard into the text input field without generating speech
- **Use Case**: Useful when you want to paste clipboard content and review/edit it before generating speech

### 3. Speak Current Text
- **Shortcut**: `⌘⇧P` (Command + Shift + P)
- **Function**: Generates speech from the current text in the input field
- **Use Case**: Quick way to generate speech without using the mouse to click the "Generate Speech" button

## How to Use

### Method 1: Menu Access
1. Open the Text-to-Speech application
2. Look for the shortcuts in the application menu (after "New Item")
3. Click on any shortcut option to execute it

### Method 2: Keyboard Shortcuts
1. Ensure the Text-to-Speech application is active/focused
2. Use the keyboard combinations listed above
3. The shortcuts work from anywhere within the application

## Workflow Examples

### Quick Text-to-Speech from Other Apps
1. Copy text from any application (web browser, document, email, etc.)
2. Switch to the Text-to-Speech app
3. Press `⌘⇧S` to instantly paste and speak the text

### Review Before Speaking
1. Copy text from any source
2. Switch to the Text-to-Speech app
3. Press `⌘⇧C` to paste the text
4. Review and edit the text if needed
5. Press `⌘⇧P` to generate speech

### Quick Re-generation
1. After editing text in the input field
2. Press `⌘⇧P` to quickly regenerate speech without reaching for the mouse

## Requirements

- The shortcuts require a voice to be selected
- For ElevenLabs voices: API key must be configured
- For OpenAI voices: API key must be configured
- Text must be present in clipboard for copy operations

## Technical Implementation

The shortcuts are implemented using:
- **SwiftUI Commands**: Menu-based shortcuts accessible via the application menu
- **ShortcutManager**: A dedicated class that manages clipboard operations and state
- **Combine Framework**: For reactive programming and state management
- **NSPasteboard**: For clipboard access and text retrieval

## Troubleshooting

### Shortcuts Not Working
- Ensure the Text-to-Speech application is the active/focused application
- Check that you're using the correct key combinations
- Verify that the required API keys are configured for your selected voice provider

### No Text Pasted
- Ensure there is text content in your system clipboard
- Try copying text again from the source application
- Check that the clipboard contains plain text (not images or other formats)

### Speech Not Generated
- Verify that a voice is selected in the application
- Check that the appropriate API key is configured
- Ensure there is text in the input field
- Check your internet connection for cloud-based voices

## Benefits

1. **Increased Productivity**: Eliminates the need for manual copy-paste operations
2. **Seamless Workflow**: Integrates smoothly with other applications
3. **Accessibility**: Provides keyboard-only access to core functionality
4. **Speed**: Reduces the time needed to convert text from other sources to speech
5. **Convenience**: Works from anywhere within the application without precise mouse targeting

## Future Enhancements

Potential future improvements could include:
- Global system shortcuts that work even when the app is not focused
- Customizable shortcut key combinations
- Batch processing of multiple clipboard items
- Integration with system services for right-click context menus