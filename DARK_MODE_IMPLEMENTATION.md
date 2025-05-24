# Dark Mode Implementation Plan

## Overview
This document outlines the implementation of a dark mode theme option for the Text-to-Speech app.

## Implementation Steps

### 1. Create ThemeManager
Create a new file `TextToSpeechApp/ThemeManager.swift` with the following functionality:
- Theme enumeration (light, dark, system)
- ObservableObject for theme state management
- UserDefaults persistence
- Color scheme management

### 2. Update SettingsView
Add theme selection controls to the existing SettingsView:
- Theme picker with light/dark/system options
- Real-time theme preview
- Persist theme selection

### 3. Update App Entry Point
Modify `TextToSpeechApp.swift` to:
- Initialize ThemeManager as environment object
- Apply color scheme based on theme selection

### 4. Update ContentView
Apply theme-aware styling throughout the UI:
- Background colors
- Text colors
- Button styling
- Border colors

## Theme Structure

### Theme Options
- **Light**: Force light appearance
- **Dark**: Force dark appearance  
- **System**: Follow system appearance

### Color Definitions
- Primary background
- Secondary background
- Primary text
- Secondary text
- Accent colors
- Border colors

## Files to Modify
1. `TextToSpeechApp/ThemeManager.swift` (new)
2. `TextToSpeechApp/TextToSpeechApp.swift`
3. `TextToSpeechApp/SettingsView.swift`
4. `TextToSpeechApp/ContentView.swift`

## Benefits
- Improved user experience in low-light conditions
- Modern app appearance
- System integration
- User preference persistence

## Next Steps
1. Switch to a mode that allows Swift file editing
2. Create ThemeManager class
3. Update Settings UI
4. Apply theme throughout app
5. Test theme switching