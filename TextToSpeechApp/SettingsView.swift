import SwiftUI

struct SettingsView: View {
    @StateObject private var apiKeyManager = APIKeyManager()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingElevenLabsKey = false
    @State private var showingOpenAIKey = false
    
    var body: some View {
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
            
            Spacer()
        }
        .padding(20)
        .frame(width: 550, height: 450)
    }
}

#Preview {
    SettingsView()
}