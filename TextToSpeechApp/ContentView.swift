import SwiftUI
import Combine
import AppKit

struct ContentView: View {
    @StateObject private var apiKeyManager = APIKeyManager()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var ttsService: TTSService?
    
    @State private var inputText = ""
    @State private var selectedProvider: TTSProvider = .openAI
    @State private var selectedVoice: Voice?
    @State private var availableVoices: [Voice] = []
    @State private var voiceControls = VoiceControls()
    
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingSettings = false
    @State private var showingVoiceControls = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Text-to-Speech")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        if let url = URL(string: "https://github.com/tmm22/TextToSpeechApp") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Contribute on GitHub")
                        }
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.blue)
                    .help("Contribute to this project on GitHub")
                    
                    Button("Voice Controls") {
                        showingVoiceControls = true
                    }
                    .buttonStyle(.borderless)
                    
                    Button("Settings") {
                        showingSettings = true
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            // Provider Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Voice Provider")
                    .font(.headline)
                
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(TTSProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedProvider) { _ in
                    updateAvailableVoices()
                }
            }
            
            // Voice Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Voice")
                    .font(.headline)
                
                if availableVoices.isEmpty {
                    Text("No voices available for \(selectedProvider.displayName)")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Picker("Voice", selection: $selectedVoice) {
                        Text("Select a voice").tag(nil as Voice?)
                        ForEach(availableVoices, id: \.id) { voice in
                            Text(voice.name).tag(voice as Voice?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if selectedProvider == .elevenLabs && !apiKeyManager.hasElevenLabsKey {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("ElevenLabs API key required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if selectedProvider == .openAI && !apiKeyManager.hasOpenAIKey {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("OpenAI API key required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Text Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Text to Speak")
                    .font(.headline)
                
                TextEditor(text: $inputText)
                    .font(.body)
                    .frame(minHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
            
            // Controls
            HStack(spacing: 16) {
                Button("Generate Speech") {
                    generateSpeech()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedVoice == nil || !hasRequiredAPIKey)
                
                if audioPlayer.isPlaying {
                    Button("Pause") {
                        audioPlayer.pause()
                    }
                    .buttonStyle(.bordered)
                } else if audioPlayer.duration > 0 {
                    Button("Play") {
                        audioPlayer.resume()
                    }
                    .buttonStyle(.bordered)
                }
                
                if audioPlayer.duration > 0 {
                    Button("Stop") {
                        audioPlayer.stop()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Audio Progress
            if audioPlayer.duration > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text(formatTime(audioPlayer.playbackProgress))
                            .font(.caption)
                            .monospacedDigit()
                        
                        Spacer()
                        
                        Text(formatTime(audioPlayer.duration))
                            .font(.caption)
                            .monospacedDigit()
                    }
                    
                    Slider(
                        value: Binding(
                            get: { audioPlayer.playbackProgress },
                            set: { audioPlayer.seek(to: $0) }
                        ),
                        in: 0...audioPlayer.duration
                    )
                }
            }
            
            // Error Display
            if let errorMessage = errorMessage ?? audioPlayer.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 600)
        .onAppear {
            setupTTSService()
            updateAvailableVoices()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingVoiceControls) {
            VoiceControlsView(
                controls: $voiceControls,
                audioPlayer: audioPlayer,
                provider: selectedProvider
            )
        }
    }
    
    private var hasRequiredAPIKey: Bool {
        switch selectedProvider {
        case .elevenLabs:
            return apiKeyManager.hasElevenLabsKey
        case .openAI:
            return apiKeyManager.hasOpenAIKey
        }
    }
    
    private func setupTTSService() {
        ttsService = TTSService(apiKeyManager: apiKeyManager)
    }
    
    private func updateAvailableVoices() {
        guard let service = ttsService else { return }
        
        // Get OpenAI voices (always available)
        let openAIVoices = OpenAIVoice.allCases.map { voice in
            Voice(id: voice.rawValue, name: voice.displayName, provider: .openAI)
        }
        
        switch selectedProvider {
        case .openAI:
            availableVoices = openAIVoices
            if selectedVoice == nil || selectedVoice?.provider != .openAI {
                selectedVoice = openAIVoices.first
            }
            
        case .elevenLabs:
            if apiKeyManager.hasElevenLabsKey {
                service.loadElevenLabsVoices()
                // The voices will be updated through the service's published property
                availableVoices = service.availableVoices.filter { $0.provider == .elevenLabs }
                selectedVoice = availableVoices.first
            } else {
                availableVoices = []
                selectedVoice = nil
            }
        }
    }
    
    private func generateSpeech() {
        guard let voice = selectedVoice,
              let service = ttsService else { return }
        
        let request = TTSRequest(
            text: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
            voice: voice,
            provider: selectedProvider,
            controls: voiceControls
        )
        
        isGenerating = true
        errorMessage = nil
        
        service.synthesizeSpeech(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    isGenerating = false
                    if case .failure(let error) = completion {
                        errorMessage = "Speech generation failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [self] audioData in
                    audioPlayer.playAudio(data: audioData)
                }
            )
            .store(in: &cancellables)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    ContentView()
}