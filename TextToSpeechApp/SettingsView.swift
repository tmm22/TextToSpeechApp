import SwiftUI

struct SettingsView: View {
    @StateObject private var apiKeyManager = APIKeyManager()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var updateChecker: UpdateChecker
    @State private var showingElevenLabsKey = false
    @State private var showingOpenAIKey = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Theme Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Appearance")
                        .font(.headline)
                    
                    Picker("Theme", selection: $themeManager.currentTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Choose your preferred appearance theme")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text("API Configuration")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ElevenLabs API Key:")
                            .fontWeight(.medium)
                        Spacer()
                        Button(showingElevenLabsKey ? "Hide" : "Show") {
                            showingElevenLabsKey.toggle()
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                    }
                    
                    if showingElevenLabsKey {
                        TextField("Enter ElevenLabs API key", text: $apiKeyManager.elevenLabsKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        SecureField("Enter ElevenLabs API key", text: $apiKeyManager.elevenLabsKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    if apiKeyManager.hasElevenLabsKey {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API key configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("OpenAI API Key:")
                            .fontWeight(.medium)
                        Spacer()
                        Button(showingOpenAIKey ? "Hide" : "Show") {
                            showingOpenAIKey.toggle()
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                    }
                    
                    if showingOpenAIKey {
                        TextField("Enter OpenAI API key", text: $apiKeyManager.openAIKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        SecureField("Enter OpenAI API key", text: $apiKeyManager.openAIKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    if apiKeyManager.hasOpenAIKey {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API key configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                // Update Settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Updates")
                        .font(.headline)
                    
                    Toggle("Check for updates automatically", isOn: $updateChecker.automaticUpdateChecksEnabled)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Version: \(updateChecker.currentVersionString)")
                                .font(.system(size: 14, weight: .medium))
                            
                            if let lastCheck = updateChecker.lastCheckDate {
                                Text("Last checked: \(lastCheck, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Update status
                            switch updateChecker.updateStatus {
                            case .checking:
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                    Text("Checking for updates...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            case .upToDate:
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text("You're up to date")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            case .updateAvailable(let release):
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text("Update available: \(release.tagName)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            case .error(let message):
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text("Error: \(message)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Check Now") {
                            updateChecker.checkForUpdates()
                        }
                        .buttonStyle(.bordered)
                        .disabled(updateChecker.isCheckingForUpdates)
                    }
                    
                    if case .updateAvailable(let release) = updateChecker.updateStatus {
                        Button("View Release") {
                            updateChecker.openReleaseURL(release)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions:")
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Get ElevenLabs API key from: elevenlabs.io")
                        Text("• Get OpenAI API key from: platform.openai.com")
                        Text("• API keys are stored securely in your system keychain")
                        Text("• Restart the app after adding keys for full functionality")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .frame(minWidth: 500, maxWidth: 600, minHeight: 400, maxHeight: 500)
    }
}

#Preview {
    SettingsView()
}