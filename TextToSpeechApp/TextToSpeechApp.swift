import SwiftUI

@main
struct TextToSpeechApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var shortcutManager = ShortcutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(shortcutManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Copy Text from Clipboard and Speak") {
                    shortcutManager.copyAndSpeak()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Button("Copy Text from Clipboard") {
                    shortcutManager.copyFromClipboard()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                
                Button("Speak Current Text") {
                    shortcutManager.speakCurrentText()
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}