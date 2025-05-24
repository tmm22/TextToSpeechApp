import Foundation
import Combine

class TTSService: ObservableObject {
    @Published var availableVoices: [Voice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKeyManager: APIKeyManager
    private var cancellables = Set<AnyCancellable>()
    
    init(apiKeyManager: APIKeyManager) {
        self.apiKeyManager = apiKeyManager
        loadDefaultVoices()
    }
    
    private func loadDefaultVoices() {
        // Add OpenAI voices (always available)
        let openAIVoices = OpenAIVoice.allCases.map { voice in
            Voice(id: voice.rawValue, name: voice.displayName, provider: .openAI)
        }
        availableVoices.append(contentsOf: openAIVoices)
    }
    
    func loadElevenLabsVoices() {
        guard apiKeyManager.hasElevenLabsKey else {
            errorMessage = "ElevenLabs API key not set"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://api.elevenlabs.io/v1/voices") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKeyManager.elevenLabsKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ElevenLabsVoicesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        let errorMsg = self?.getNetworkErrorMessage(error) ?? "Unknown error"
                        self?.errorMessage = "Failed to load ElevenLabs voices: \(errorMsg)"
                    }
                },
                receiveValue: { [weak self] response in
                    let elevenLabsVoices = response.voices.map { voice in
                        Voice(id: voice.voice_id, name: voice.name, provider: .elevenLabs)
                    }
                    
                    // Remove existing ElevenLabs voices and add new ones
                    self?.availableVoices.removeAll { $0.provider == .elevenLabs }
                    self?.availableVoices.append(contentsOf: elevenLabsVoices)
                }
            )
            .store(in: &cancellables)
    }
    
    func synthesizeSpeech(request: TTSRequest) -> AnyPublisher<Data, Error> {
        switch request.provider {
        case .elevenLabs:
            return synthesizeElevenLabs(text: request.text, voiceId: request.voice.id, controls: request.controls)
        case .openAI:
            return synthesizeOpenAI(text: request.text, voice: request.voice.id, controls: request.controls)
        }
    }
    
    private func synthesizeElevenLabs(text: String, voiceId: String, controls: VoiceControls) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)") else {
            return Fail(error: TTSError.invalidURL).eraseToAnyPublisher()
        }
        
        let emotionSettings = controls.emotion.elevenLabsSettings
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": emotionSettings.stability,
                "similarity_boost": emotionSettings.similarityBoost,
                "style": emotionSettings.style,
                "use_speaker_boost": emotionSettings.useSpeakerBoost
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: TTSError.encodingError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKeyManager.elevenLabsKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    private func synthesizeOpenAI(text: String, voice: String, controls: VoiceControls) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: "https://api.openai.com/v1/audio/speech") else {
            return Fail(error: TTSError.invalidURL).eraseToAnyPublisher()
        }
        
        let requestBody: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": voice,
            "speed": max(0.25, min(4.0, controls.speed)) // OpenAI supports 0.25 to 4.0
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: TTSError.encodingError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKeyManager.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    private func getNetworkErrorMessage(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection"
            case .cannotFindHost:
                return "Cannot connect to server. Check your network connection and ensure the app has network permissions."
            case .timedOut:
                return "Request timed out"
            case .cannotConnectToHost:
                return "Cannot connect to host"
            case .networkConnectionLost:
                return "Network connection lost"
            default:
                return "Network error: \(urlError.localizedDescription)"
            }
        }
        return error.localizedDescription
    }
}

enum TTSError: LocalizedError {
    case invalidURL
    case encodingError
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .noAPIKey:
            return "API key not provided"
        }
    }
}