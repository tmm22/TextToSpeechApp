import SwiftUI

@main
struct TextToSpeechApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
        }
    }
}