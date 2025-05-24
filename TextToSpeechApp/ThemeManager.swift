import SwiftUI
import Foundation

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        // Ensure dark mode is the default theme
        // Check if there's a saved theme preference, but default to dark mode
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        
        if let savedTheme = savedTheme, let theme = AppTheme(rawValue: savedTheme) {
            // Use saved theme if it exists and is valid
            self.currentTheme = theme
        } else {
            // Default to dark mode if no saved preference or invalid preference
            self.currentTheme = .dark
            UserDefaults.standard.set(AppTheme.dark.rawValue, forKey: "selectedTheme")
        }
    }
    
    var preferredColorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
    
    // Method to reset theme to dark mode (useful for ensuring dark mode is default)
    func resetToDefaultDarkMode() {
        print("Resetting theme to dark mode")
        UserDefaults.standard.set(AppTheme.dark.rawValue, forKey: "selectedTheme")
        self.currentTheme = .dark
    }
    
    // Method to check if this is the first launch (no theme preference saved)
    var isFirstLaunch: Bool {
        return UserDefaults.standard.string(forKey: "selectedTheme") == nil
    }
}