import SwiftUI
import Combine
import AppKit

struct ContentView: View {
    @StateObject private var apiKeyManager = APIKeyManager()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var ttsService: TTSService?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var shortcutManager: ShortcutManager
    @EnvironmentObject var updateChecker: UpdateChecker
    
    @State private var inputText = ""
    @State private var selectedProvider: TTSProvider = .openAI
    @State private var selectedVoice: Voice?
    @State private var availableVoices: [Voice] = []
    @State private var voiceControls = VoiceControls()
    
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingSettings = false
    @State private var showingVoiceControls = false
    @State private var showingEmotionTester = false
    @State private var showingQuickActions = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Minimal Header with floating controls
                    headerView
                    
                    // Update notification banner
                    if updateChecker.shouldShowUpdateNotification {
                        updateNotificationBanner
                    }
                    
                    // Main content area
                    mainContentView
                        .frame(minHeight: max(400, geometry.size.height - 200))
                    
                    // Floating bottom controls
                    if audioPlayer.duration > 0 || isGenerating {
                        bottomControlsView
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(backgroundGradient)
        .preferredColorScheme(themeManager.preferredColorScheme)
        .onAppear {
            setupTTSService()
            updateAvailableVoices()
            setupShortcutObservers()
        }
        .onChange(of: selectedProvider) { _ in
            updateAvailableVoices()
        }
        .onChange(of: apiKeyManager.elevenLabsKey) { _ in
            if selectedProvider == .elevenLabs {
                updateAvailableVoices()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingVoiceControls) {
            VoiceControlsView(
                controls: $voiceControls,
                audioPlayer: audioPlayer,
                provider: selectedProvider
            )
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingEmotionTester) {
            if let service = ttsService {
                EmotionTesterView(ttsService: service, apiKeyManager: apiKeyManager)
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // App title - minimal
            Text("TTS")
                .font(.system(size: 24, weight: .light, design: .rounded))
                .foregroundColor(.primary.opacity(0.8))
            
            Spacer()
            
            // Quick action button
            Button(action: { showingQuickActions.toggle() }) {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.primary.opacity(0.6))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingQuickActions, arrowEdge: .top) {
                quickActionsMenu
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: Rectangle())
    }
    
    // MARK: - Quick Actions Menu
    private var quickActionsMenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            quickActionButton("Voice Controls", systemImage: "waveform.circle") {
                showingVoiceControls = true
                showingQuickActions = false
            }
            
            quickActionButton("Emotion Tester", systemImage: "theatermasks") {
                showingEmotionTester = true
                showingQuickActions = false
            }
            
            quickActionButton("Settings", systemImage: "gear") {
                showingSettings = true
                showingQuickActions = false
            }
            
            quickActionButton("Check for Updates", systemImage: "arrow.down.circle") {
                updateChecker.checkForUpdates()
                showingQuickActions = false
            }
            
            Divider()
            
            quickActionButton("GitHub", systemImage: "heart.fill") {
                if let url = URL(string: "https://github.com/tmm22/TextToSpeechApp") {
                    NSWorkspace.shared.open(url)
                }
                showingQuickActions = false
            }
        }
        .padding(16)
        .frame(width: 180)
    }
    
    private func quickActionButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Provider selection - minimal pills
            providerSelectionView
            
            // Voice selection - streamlined
            voiceSelectionView
            
            // Text input - clean and focused
            textInputView
            
            // Generate button - prominent
            generateButtonView
            
            // Error display - subtle
            if let errorMessage = errorMessage ?? audioPlayer.errorMessage {
                errorView(errorMessage)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Provider Selection
    private var providerSelectionView: some View {
        HStack(spacing: 16) {
            ForEach(TTSProvider.allCases, id: \.self) { provider in
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedProvider = provider
                    }
                }) {
                    Text(provider.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedProvider == provider ? .white : .primary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedProvider == provider ? 
                                      Color.accentColor : 
                                      Color.primary.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Voice Selection
    private var voiceSelectionView: some View {
        VStack(spacing: 8) {
            if !availableVoices.isEmpty {
                Menu {
                    ForEach(availableVoices, id: \.id) { voice in
                        Button(voice.name) {
                            selectedVoice = voice
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedVoice?.name ?? "Select Voice")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            
            // API key warning - subtle
            if !hasRequiredAPIKey {
                HStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 12))
                    Text("\(selectedProvider.displayName) API key required")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.orange.opacity(0.8))
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Text Input
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $inputText)
                .font(.system(size: 16, weight: .regular))
                .scrollContentBackground(.hidden)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .frame(minHeight: 120, idealHeight: 150, maxHeight: 250)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    // Placeholder text
                    Group {
                        if inputText.isEmpty {
                            VStack {
                                HStack {
                                    Text("Enter text to speak...")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary.opacity(0.4))
                                        .padding(.leading, 20)
                                        .padding(.top, 20)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                )
        }
    }
    
    // MARK: - Generate Button
    private var generateButtonView: some View {
        Button(action: generateSpeech) {
            HStack(spacing: 12) {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isGenerating ? "Generating..." : "Generate Speech")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        canGenerate ? 
                        Color.accentColor : 
                        Color.primary.opacity(0.3)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!canGenerate)
        .scaleEffect(canGenerate ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: canGenerate)
    }
    
    // MARK: - Bottom Controls
    private var bottomControlsView: some View {
        VStack(spacing: 16) {
            // Audio progress
            if audioPlayer.duration > 0 {
                audioProgressView
            }
            
            // Playback controls
            playbackControlsView
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Audio Progress
    private var audioProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text(formatTime(audioPlayer.playbackProgress))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
                
                Spacer()
                
                Text(formatTime(audioPlayer.duration))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
            }
            
            Slider(
                value: Binding(
                    get: { audioPlayer.playbackProgress },
                    set: { audioPlayer.seek(to: $0) }
                ),
                in: 0...audioPlayer.duration
            )
            .tint(.accentColor)
        }
    }
    
    // MARK: - Playback Controls
    private var playbackControlsView: some View {
        HStack(spacing: 20) {
            if audioPlayer.isPlaying {
                controlButton("pause.fill") {
                    audioPlayer.pause()
                }
            } else if audioPlayer.duration > 0 {
                controlButton("play.fill") {
                    audioPlayer.resume()
                }
            }
            
            if audioPlayer.duration > 0 {
                controlButton("stop.fill") {
                    audioPlayer.stop()
                }
            }
        }
    }
    
    private func controlButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: themeManager.currentTheme == .dark ? 
                [Color.black, Color.gray.opacity(0.1)] :
                [Color.white, Color.blue.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Computed Properties
    private var canGenerate: Bool {
        !isGenerating && 
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        selectedVoice != nil && 
        hasRequiredAPIKey
    }
    
    private var hasRequiredAPIKey: Bool {
        switch selectedProvider {
        case .elevenLabs:
            return apiKeyManager.hasElevenLabsKey
        case .openAI:
            return apiKeyManager.hasOpenAIKey
        }
    }
    
    // MARK: - Methods
    private func setupTTSService() {
        ttsService = TTSService(apiKeyManager: apiKeyManager)
    }
    
    private func updateAvailableVoices() {
        guard let service = ttsService else { return }
        
        
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
                // Clear any existing ElevenLabs voice observers
                cancellables.removeAll()
                
                // Load ElevenLabs voices and observe the service for updates
                service.loadElevenLabsVoices()
                
                // Set up observer for when ElevenLabs voices are loaded
                service.$availableVoices
                    .receive(on: DispatchQueue.main)
                    .sink { voices in
                        let elevenLabsVoices = voices.filter { $0.provider == .elevenLabs }
                        if !elevenLabsVoices.isEmpty && selectedProvider == .elevenLabs {
                            availableVoices = elevenLabsVoices
                            if selectedVoice?.provider != .elevenLabs {
                                selectedVoice = elevenLabsVoices.first
                            }
                        }
                    }
                    .store(in: &cancellables)
                
                // Immediately show any existing ElevenLabs voices
                let existingElevenLabsVoices = service.availableVoices.filter { $0.provider == .elevenLabs }
                if !existingElevenLabsVoices.isEmpty {
                    availableVoices = existingElevenLabsVoices
                    if selectedVoice?.provider != .elevenLabs {
                        selectedVoice = existingElevenLabsVoices.first
                    }
                } else {
                    availableVoices = []
                    selectedVoice = nil
                }
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
    
    private func setupShortcutObservers() {
        shortcutManager.$shouldCopyFromClipboard
            .sink { shouldCopy in
                if shouldCopy {
                    self.handleCopyFromClipboard()
                    DispatchQueue.main.async {
                        self.shortcutManager.shouldCopyFromClipboard = false
                    }
                }
            }
            .store(in: &cancellables)
        
        shortcutManager.$shouldSpeakCurrentText
            .sink { shouldSpeak in
                if shouldSpeak {
                    self.handleSpeakCurrentText()
                    DispatchQueue.main.async {
                        self.shortcutManager.shouldSpeakCurrentText = false
                    }
                }
            }
            .store(in: &cancellables)
        
        shortcutManager.$shouldCopyAndSpeak
            .sink { shouldCopyAndSpeak in
                if shouldCopyAndSpeak {
                    self.handleCopyAndSpeak()
                    DispatchQueue.main.async {
                        self.shortcutManager.shouldCopyAndSpeak = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleCopyFromClipboard() {
        if let clipboardText = shortcutManager.getClipboardText() {
            inputText = clipboardText
        }
    }
    
    private func handleSpeakCurrentText() {
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            generateSpeech()
        }
    }
    
    private func handleCopyAndSpeak() {
        if let clipboardText = shortcutManager.getClipboardText() {
            inputText = clipboardText
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.generateSpeech()
                }
            }
        }
    }
    
    // MARK: - Update Notification Banner
    private var updateNotificationBanner: some View {
        Group {
            if case .updateAvailable(let release) = updateChecker.updateStatus {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Update Available")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Version \(release.tagName) is now available")
                                .font(.system(size: 14))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button("View Release") {
                            updateChecker.openReleaseURL(release)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                updateChecker.updateStatus = .upToDate
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(ShortcutManager())
}