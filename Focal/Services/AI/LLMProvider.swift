import Foundation

enum LLMProvider: String, CaseIterable, Codable {
    case gemini = "Google Gemini"
    case openAI = "OpenAI"
    case anthropic = "Anthropic Claude"
    case apple = "Apple Intelligence"

    var modelName: String {
        switch self {
        case .gemini: return "gemini-2.0-flash"
        case .openAI: return "gpt-4o-mini"
        case .anthropic: return "claude-3-5-haiku-latest"
        case .apple: return "on-device"
        }
    }

    var baseURL: URL? {
        switch self {
        case .gemini: return URL(string: "https://generativelanguage.googleapis.com/v1beta")
        case .openAI: return URL(string: "https://api.openai.com/v1")
        case .anthropic: return URL(string: "https://api.anthropic.com/v1")
        case .apple: return nil // On-device
        }
    }

    var requiresAPIKey: Bool {
        self != .apple
    }

    var apiKeyPlaceholder: String {
        switch self {
        case .gemini: return "AIza..."
        case .openAI: return "sk-..."
        case .anthropic: return "sk-ant-..."
        case .apple: return ""
        }
    }

    var setupInstructions: String {
        switch self {
        case .gemini:
            return "Get your API key from Google AI Studio:\nhttps://aistudio.google.com/apikey"
        case .openAI:
            return "Get your API key from OpenAI:\nhttps://platform.openai.com/api-keys"
        case .anthropic:
            return "Get your API key from Anthropic Console:\nhttps://console.anthropic.com/settings/keys"
        case .apple:
            return "Uses on-device Apple Intelligence.\nRequires iOS 18.4+ and compatible device."
        }
    }

    var isAvailable: Bool {
        switch self {
        case .apple:
            if #available(iOS 18.4, *) {
                // Check if device supports Apple Intelligence
                return true // Will add proper check when FoundationModels is available
            }
            return false
        default:
            return true
        }
    }
}

struct LLMConfig {
    let provider: LLMProvider
    let apiKey: String?
    var temperature: Double = 0.3
    var maxTokens: Int = 1000

    static func forProvider(_ provider: LLMProvider) -> LLMConfig {
        let apiKey = KeychainManager.shared.getAPIKey(for: provider)
        return LLMConfig(provider: provider, apiKey: apiKey)
    }
}
