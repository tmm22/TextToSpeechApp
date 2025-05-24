import SwiftUI
import Combine
import Foundation

class EmotionTester: ObservableObject {
    @Published var isRunning = false
    @Published var currentEmotion: VoiceEmotion?
    @Published var progress: Double = 0.0
    @Published var testResults: [EmotionTestResult] = []
    @Published var errorMessage: String?
    @Published var logMessages: [String] = []
    
    private let ttsService: TTSService
    private let apiKeyManager: APIKeyManager
    private var cancellables = Set<AnyCancellable>()
    private let testPhrase = "This is a test of the {emotion} voice emotion. The quick brown fox jumps over the lazy dog."
    
    init(ttsService: TTSService, apiKeyManager: APIKeyManager) {
        self.ttsService = ttsService
        self.apiKeyManager = apiKeyManager
    }
    
    func runEmotionTests(provider: TTSProvider, voice: Voice) {
        guard !isRunning else { return }
        
        // Validate prerequisites
        guard validatePrerequisites(provider: provider) else { return }
        
        isRunning = true
        currentEmotion = nil
        progress = 0.0
        testResults.removeAll()
        errorMessage = nil
        logMessages.removeAll()
        
        addLogMessage("Starting emotion tests for \(provider.displayName) with voice: \(voice.name)")
        addLogMessage("Test phrase: \(testPhrase)")
        
        let emotions = VoiceEmotion.allCases
        let totalEmotions = emotions.count
        
        testEmotionsSequentially(emotions: emotions, provider: provider, voice: voice, currentIndex: 0, totalCount: totalEmotions)
    }
    
    private func validatePrerequisites(provider: TTSProvider) -> Bool {
        switch provider {
        case .elevenLabs:
            if !apiKeyManager.hasElevenLabsKey {
                errorMessage = "ElevenLabs API key is required for testing"
                return false
            }
        case .openAI:
            if !apiKeyManager.hasOpenAIKey {
                errorMessage = "OpenAI API key is required for testing"
                return false
            }
        }
        return true
    }
    
    private func testEmotionsSequentially(emotions: [VoiceEmotion], provider: TTSProvider, voice: Voice, currentIndex: Int, totalCount: Int) {
        guard currentIndex < emotions.count else {
            // All tests completed
            completeTests()
            return
        }
        
        let emotion = emotions[currentIndex]
        currentEmotion = emotion
        progress = Double(currentIndex) / Double(totalCount)
        
        addLogMessage("Testing emotion: \(emotion.displayName)")
        
        // Log ElevenLabs parameters for this emotion
        if provider == .elevenLabs {
            let settings = emotion.elevenLabsSettings
            addLogMessage("ElevenLabs parameters - Stability: \(settings.stability), Similarity Boost: \(settings.similarityBoost), Style: \(settings.style), Speaker Boost: \(settings.useSpeakerBoost)")
        }
        
        testSingleEmotion(emotion: emotion, provider: provider, voice: voice) { [weak self] result in
            DispatchQueue.main.async {
                self?.testResults.append(result)
                
                if result.success {
                    self?.addLogMessage("✅ \(emotion.displayName) test completed successfully")
                } else {
                    self?.addLogMessage("❌ \(emotion.displayName) test failed: \(result.errorMessage ?? "Unknown error")")
                }
                
                // Continue with next emotion after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.testEmotionsSequentially(emotions: emotions, provider: provider, voice: voice, currentIndex: currentIndex + 1, totalCount: totalCount)
                }
            }
        }
    }
    
    private func testSingleEmotion(emotion: VoiceEmotion, provider: TTSProvider, voice: Voice, completion: @escaping (EmotionTestResult) -> Void) {
        let testText = testPhrase.replacingOccurrences(of: "{emotion}", with: emotion.displayName.lowercased())
        
        var voiceControls = VoiceControls()
        voiceControls.emotion = emotion
        
        let request = TTSRequest(
            text: testText,
            voice: voice,
            provider: provider,
            controls: voiceControls
        )
        
        let startTime = Date()
        
        ttsService.synthesizeSpeech(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completionResult in
                    let endTime = Date()
                    let duration = endTime.timeIntervalSince(startTime)
                    
                    switch completionResult {
                    case .failure(let error):
                        let result = EmotionTestResult(
                            emotion: emotion,
                            success: false,
                            audioData: nil,
                            duration: duration,
                            errorMessage: error.localizedDescription,
                            parameters: provider == .elevenLabs ? emotion.elevenLabsSettings : nil
                        )
                        completion(result)
                    case .finished:
                        break
                    }
                },
                receiveValue: { audioData in
                    let endTime = Date()
                    let duration = endTime.timeIntervalSince(startTime)
                    
                    let result = EmotionTestResult(
                        emotion: emotion,
                        success: true,
                        audioData: audioData,
                        duration: duration,
                        errorMessage: nil,
                        parameters: provider == .elevenLabs ? emotion.elevenLabsSettings : nil
                    )
                    
                    // Save audio file
                    self.saveAudioFile(audioData: audioData, emotion: emotion, provider: provider)
                    
                    completion(result)
                }
            )
            .store(in: &cancellables)
    }
    
    private func saveAudioFile(audioData: Data, emotion: VoiceEmotion, provider: TTSProvider) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let emotionTestsFolder = documentsPath.appendingPathComponent("EmotionTests")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: emotionTestsFolder, withIntermediateDirectories: true)
        
        let fileName = "\(emotion.rawValue)_test_\(provider.rawValue.lowercased()).mp3"
        let fileURL = emotionTestsFolder.appendingPathComponent(fileName)
        
        do {
            try audioData.write(to: fileURL)
            addLogMessage("💾 Saved audio file: \(fileName)")
        } catch {
            addLogMessage("⚠️ Failed to save audio file for \(emotion.displayName): \(error.localizedDescription)")
        }
    }
    
    private func completeTests() {
        isRunning = false
        currentEmotion = nil
        progress = 1.0
        
        let successCount = testResults.filter { $0.success }.count
        let totalCount = testResults.count
        
        addLogMessage("🎉 Testing completed! \(successCount)/\(totalCount) emotions tested successfully")
        
        if successCount < totalCount {
            let failedEmotions = testResults.filter { !$0.success }.map { $0.emotion.displayName }
            addLogMessage("❌ Failed emotions: \(failedEmotions.joined(separator: ", "))")
        }
        
        // Show file location
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let emotionTestsFolder = documentsPath.appendingPathComponent("EmotionTests")
        addLogMessage("📁 Audio files saved to: \(emotionTestsFolder.path)")
    }
    
    func stopTests() {
        isRunning = false
        currentEmotion = nil
        cancellables.removeAll()
        addLogMessage("🛑 Tests stopped by user")
    }
    
    private func addLogMessage(_ message: String) {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        logMessages.append("[\(timestamp)] \(message)")
    }
    
    func clearResults() {
        testResults.removeAll()
        logMessages.removeAll()
        errorMessage = nil
        progress = 0.0
    }
    
    func verifyEmotionParameters(emotion: VoiceEmotion) -> Bool {
        let settings = emotion.elevenLabsSettings
        
        // Verify parameters are within expected ranges
        let stabilityValid = settings.stability >= 0.0 && settings.stability <= 1.0
        let similarityBoostValid = settings.similarityBoost >= 0.0 && settings.similarityBoost <= 1.0
        let styleValid = settings.style >= 0.0 && settings.style <= 1.0
        
        return stabilityValid && similarityBoostValid && styleValid
    }
    
    func exportTestResults() -> String {
        var report = "Emotion Test Results\n"
        report += "===================\n\n"
        report += "Test completed at: \(DateFormatter.fullFormatter.string(from: Date()))\n"
        report += "Total emotions tested: \(testResults.count)\n"
        report += "Successful tests: \(testResults.filter { $0.success }.count)\n\n"
        
        for result in testResults {
            report += "Emotion: \(result.emotion.displayName)\n"
            report += "Status: \(result.success ? "✅ Success" : "❌ Failed")\n"
            report += "Duration: \(String(format: "%.2f", result.duration))s\n"
            
            if let params = result.parameters {
                report += "Parameters: Stability=\(params.stability), SimilarityBoost=\(params.similarityBoost), Style=\(params.style), SpeakerBoost=\(params.useSpeakerBoost)\n"
            }
            
            if let error = result.errorMessage {
                report += "Error: \(error)\n"
            }
            
            report += "\n"
        }
        
        return report
    }
}

struct EmotionTestResult {
    let emotion: VoiceEmotion
    let success: Bool
    let audioData: Data?
    let duration: TimeInterval
    let errorMessage: String?
    let parameters: (stability: Double, similarityBoost: Double, style: Double, useSpeakerBoost: Bool)?
}

struct EmotionTesterView: View {
    @StateObject private var emotionTester: EmotionTester
    @State private var selectedProvider: TTSProvider = .elevenLabs
    @State private var selectedVoice: Voice?
    @State private var availableVoices: [Voice] = []
    @State private var showingResults = false
    
    private let ttsService: TTSService
    private let apiKeyManager: APIKeyManager
    
    init(ttsService: TTSService, apiKeyManager: APIKeyManager) {
        self.ttsService = ttsService
        self.apiKeyManager = apiKeyManager
        self._emotionTester = StateObject(wrappedValue: EmotionTester(ttsService: ttsService, apiKeyManager: apiKeyManager))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Emotion Tester")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Provider and Voice Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Test Configuration")
                    .font(.headline)
                
                HStack {
                    Text("Provider:")
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
                
                HStack {
                    Text("Voice:")
                    Picker("Voice", selection: $selectedVoice) {
                        Text("Select a voice").tag(nil as Voice?)
                        ForEach(availableVoices, id: \.id) { voice in
                            Text(voice.name).tag(voice as Voice?)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(availableVoices.isEmpty)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Test Progress
            if emotionTester.isRunning {
                VStack(spacing: 8) {
                    HStack {
                        Text("Testing:")
                        Text(emotionTester.currentEmotion?.displayName ?? "Preparing...")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(Int(emotionTester.progress * 100))%")
                    }
                    
                    ProgressView(value: emotionTester.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Control Buttons
            HStack(spacing: 16) {
                if emotionTester.isRunning {
                    Button("Stop Tests") {
                        emotionTester.stopTests()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                } else {
                    Button("Run Emotion Tests") {
                        guard let voice = selectedVoice else { return }
                        emotionTester.runEmotionTests(provider: selectedProvider, voice: voice)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedVoice == nil || !hasRequiredAPIKey)
                }
                
                Button("Clear Results") {
                    emotionTester.clearResults()
                }
                .buttonStyle(.bordered)
                .disabled(emotionTester.isRunning)
                
                Button("View Results") {
                    showingResults = true
                }
                .buttonStyle(.bordered)
                .disabled(emotionTester.testResults.isEmpty)
            }
            
            // Error Message
            if let errorMessage = emotionTester.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Quick Results Summary
            if !emotionTester.testResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Summary")
                        .font(.headline)
                    
                    let successCount = emotionTester.testResults.filter { $0.success }.count
                    let totalCount = emotionTester.testResults.count
                    
                    Text("Completed: \(successCount)/\(totalCount) emotions")
                    
                    if successCount < totalCount {
                        let failedEmotions = emotionTester.testResults.filter { !$0.success }.map { $0.emotion.displayName }
                        Text("Failed: \(failedEmotions.joined(separator: ", "))")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            updateAvailableVoices()
        }
        .sheet(isPresented: $showingResults) {
            EmotionTestResultsView(emotionTester: emotionTester)
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
    
    private func updateAvailableVoices() {
        switch selectedProvider {
        case .openAI:
            availableVoices = OpenAIVoice.allCases.map { voice in
                Voice(id: voice.rawValue, name: voice.displayName, provider: .openAI)
            }
            selectedVoice = availableVoices.first
            
        case .elevenLabs:
            if apiKeyManager.hasElevenLabsKey {
                ttsService.loadElevenLabsVoices()
                availableVoices = ttsService.availableVoices.filter { $0.provider == .elevenLabs }
                selectedVoice = availableVoices.first
            } else {
                availableVoices = []
                selectedVoice = nil
            }
        }
    }
}

struct EmotionTestResultsView: View {
    @ObservedObject var emotionTester: EmotionTester
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Results List
                List {
                    Section("Test Results") {
                        ForEach(emotionTester.testResults, id: \.emotion.rawValue) { result in
                            HStack {
                                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(result.success ? .green : .red)
                                
                                VStack(alignment: .leading) {
                                    Text(result.emotion.displayName)
                                        .fontWeight(.semibold)
                                    
                                    if let params = result.parameters {
                                        Text("Stability: \(String(format: "%.2f", params.stability)), Style: \(String(format: "%.2f", params.style))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let error = result.errorMessage {
                                        Text(error)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("\(String(format: "%.2f", result.duration))s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section("Log Messages") {
                        ForEach(emotionTester.logMessages, id: \.self) { message in
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Export Button
                Button("Export Results") {
                    let report = emotionTester.exportTestResults()
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(report, forType: .string)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Test Results")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

// Helper extensions
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    static let fullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter
    }()
}