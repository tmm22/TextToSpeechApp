import SwiftUI

@main
struct TextToSpeechApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}