import Foundation

@Observable
final class LLMService {

    // MARK: - State

    var isConfigured: Bool = false
    var currentProvider: LLMProvider = .gemini
    var isLoading: Bool = false

    // MARK: - Private

    private let session: URLSession
    private var config: LLMConfig?

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)

        loadConfiguration()
    }

    // MARK: - Configuration

    func configure(provider: LLMProvider, apiKey: String) {
        self.currentProvider = provider
        self.config = LLMConfig(provider: provider, apiKey: apiKey)
        self.isConfigured = true

        // Save to keychain
        KeychainManager.shared.saveAPIKey(apiKey, for: provider)
        UserDefaults.standard.set(provider.rawValue, forKey: "selectedLLMProvider")
    }

    private func loadConfiguration() {
        if let providerRaw = UserDefaults.standard.string(forKey: "selectedLLMProvider"),
           let provider = LLMProvider(rawValue: providerRaw) {
            self.currentProvider = provider
            if let apiKey = KeychainManager.shared.getAPIKey(for: provider) {
                self.config = LLMConfig(provider: provider, apiKey: apiKey)
                self.isConfigured = true
            }
        }
    }

    // MARK: - Core API

    /// Send a prompt and get a response
    func complete(
        prompt: String,
        systemPrompt: String? = nil,
        temperature: Double = 0.3,
        maxTokens: Int = 1000
    ) async throws -> String {
        guard let config, isConfigured else {
            throw LLMError.notConfigured
        }

        isLoading = true
        defer { isLoading = false }

        switch config.provider {
        case .gemini:
            return try await callGemini(prompt: prompt, system: systemPrompt, config: config)
        case .openAI:
            return try await callOpenAI(prompt: prompt, system: systemPrompt, config: config)
        case .anthropic:
            return try await callAnthropic(prompt: prompt, system: systemPrompt, config: config)
        case .apple:
            return try await callAppleIntelligence(prompt: prompt, system: systemPrompt)
        }
    }

    /// Send prompt and parse JSON response
    func completeJSON<T: Decodable>(
        prompt: String,
        systemPrompt: String? = nil,
        responseType: T.Type
    ) async throws -> T {
        let response = try await complete(prompt: prompt, systemPrompt: systemPrompt)

        // Extract JSON from response (may be wrapped in markdown code blocks)
        let jsonString = extractJSON(from: response)

        guard let data = jsonString.data(using: .utf8) else {
            throw LLMError.parsingFailed("Invalid UTF-8")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw LLMError.parsingFailed(error.localizedDescription)
        }
    }

    // MARK: - Provider Implementations

    private func callGemini(prompt: String, system: String?, config: LLMConfig) async throws -> String {
        guard let apiKey = config.apiKey else { throw LLMError.invalidAPIKey }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(config.provider.modelName):generateContent?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var contents: [[String: Any]] = []

        if let system {
            contents.append([
                "role": "user",
                "parts": [["text": system]]
            ])
            contents.append([
                "role": "model",
                "parts": [["text": "I understand. I'll follow these instructions."]]
            ])
        }

        contents.append([
            "role": "user",
            "parts": [["text": prompt]]
        ])

        let body: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": config.temperature,
                "maxOutputTokens": config.maxTokens,
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data, provider: .gemini)

        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = result.candidates?.first?.content.parts.first?.text else {
            throw LLMError.invalidResponse
        }

        return text
    }

    private func callOpenAI(prompt: String, system: String?, config: LLMConfig) async throws -> String {
        guard let apiKey = config.apiKey else { throw LLMError.invalidAPIKey }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var messages: [[String: String]] = []

        if let system {
            messages.append(["role": "system", "content": system])
        }
        messages.append(["role": "user", "content": prompt])

        let body: [String: Any] = [
            "model": config.provider.modelName,
            "messages": messages,
            "temperature": config.temperature,
            "max_tokens": config.maxTokens,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data, provider: .openAI)

        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let text = result.choices.first?.message.content else {
            throw LLMError.invalidResponse
        }

        return text
    }

    private func callAnthropic(prompt: String, system: String?, config: LLMConfig) async throws -> String {
        guard let apiKey = config.apiKey else { throw LLMError.invalidAPIKey }

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "model": config.provider.modelName,
            "max_tokens": config.maxTokens,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        if let system {
            body["system"] = system
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data, provider: .anthropic)

        let result = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let text = result.content.first?.text else {
            throw LLMError.invalidResponse
        }

        return text
    }

    private func callAppleIntelligence(prompt: String, system: String?) async throws -> String {
        // Apple Intelligence integration
        // Uses FoundationModels framework - available iOS 18.4+
        // This will be implemented when FoundationModels SDK is available
        throw LLMError.providerUnavailable
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse, data: Data, provider: LLMProvider) throws {
        guard let http = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw LLMError.invalidAPIKey
        case 429:
            let retryAfter = http.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) }
            throw LLMError.rateLimited(retryAfter: retryAfter)
        case 500...599:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.serverError(statusCode: http.statusCode, message: message)
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.serverError(statusCode: http.statusCode, message: message)
        }
    }

    func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.hasPrefix("```json") {
            result = String(result.dropFirst(7))
        } else if result.hasPrefix("```") {
            result = String(result.dropFirst(3))
        }

        if result.hasSuffix("```") {
            result = String(result.dropLast(3))
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Response Models

struct GeminiResponse: Codable {
    struct Candidate: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String?
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]?
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

struct AnthropicResponse: Codable {
    struct Content: Codable {
        let text: String
    }
    let content: [Content]
}
