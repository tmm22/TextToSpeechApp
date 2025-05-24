import Foundation

enum TTSProvider: String, CaseIterable {
    case elevenLabs = "ElevenLabs"
    case openAI = "OpenAI"
    
    var displayName: String {
        return rawValue
    }
}

struct Voice: Identifiable, Hashable {
    let id: String
    let name: String
    let provider: TTSProvider
}

// ElevenLabs Voice Models
struct ElevenLabsVoicesResponse: Codable {
    let voices: [ElevenLabsVoice]
}

struct ElevenLabsVoice: Codable {
    let voice_id: String
    let name: String
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case voice_id, name, category
    }
}

// OpenAI Voice Models
enum OpenAIVoice: String, CaseIterable {
    case alloy = "alloy"
    case echo = "echo"
    case fable = "fable"
    case onyx = "onyx"
    case nova = "nova"
    case shimmer = "shimmer"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

// Voice Control Settings
struct VoiceControls {
    var speed: Double = 1.0        // 0.25 to 4.0 for OpenAI, 0.5 to 2.0 for ElevenLabs
    var pitch: Double = 1.0        // 0.5 to 2.0 (will be simulated for providers that don't support it)
    var volume: Double = 1.0       // 0.0 to 1.0
    var emotion: VoiceEmotion = .neutral
}

// Voice Emotion Presets
enum VoiceEmotion: String, CaseIterable {
    case neutral = "neutral"
    case happy = "happy"
    case sad = "sad"
    case excited = "excited"
    case calm = "calm"
    case angry = "angry"
    case whisper = "whisper"
    case dramatic = "dramatic"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    // ElevenLabs voice settings for emotions
    var elevenLabsSettings: (stability: Double, similarityBoost: Double, style: Double, useSpeakerBoost: Bool) {
        switch self {
        case .neutral:
            return (0.5, 0.5, 0.0, false)
        case .happy:
            return (0.3, 0.8, 0.3, true)
        case .sad:
            return (0.8, 0.3, 0.0, false)
        case .excited:
            return (0.2, 0.9, 0.5, true)
        case .calm:
            return (0.9, 0.2, 0.0, false)
        case .angry:
            return (0.4, 0.7, 0.4, true)
        case .whisper:
            return (0.9, 0.1, 0.0, false)
        case .dramatic:
            return (0.3, 0.6, 0.6, true)
        }
    }
}

// TTS Request Models
struct TTSRequest {
    let text: String
    let voice: Voice
    let provider: TTSProvider
    let controls: VoiceControls
}

// API Key Storage
class APIKeyManager: ObservableObject {
    @Published var elevenLabsKey: String {
        didSet {
            UserDefaults.standard.set(elevenLabsKey, forKey: "elevenLabsAPIKey")
        }
    }
    
    @Published var openAIKey: String {
        didSet {
            UserDefaults.standard.set(openAIKey, forKey: "openAIAPIKey")
        }
    }
    
    init() {
        self.elevenLabsKey = UserDefaults.standard.string(forKey: "elevenLabsAPIKey") ?? ""
        self.openAIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
    }
    
    var hasElevenLabsKey: Bool {
        !elevenLabsKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasOpenAIKey: Bool {
        !openAIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}