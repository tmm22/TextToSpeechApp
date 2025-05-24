import SwiftUI
import AppKit

class ShortcutManager: ObservableObject {
    @Published var shouldCopyFromClipboard = false
    @Published var shouldSpeakCurrentText = false
    @Published var shouldCopyAndSpeak = false
    
    func copyFromClipboard() {
        shouldCopyFromClipboard = true
    }
    
    func speakCurrentText() {
        shouldSpeakCurrentText = true
    }
    
    func copyAndSpeak() {
        shouldCopyAndSpeak = true
    }
    
    func getClipboardText() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
}