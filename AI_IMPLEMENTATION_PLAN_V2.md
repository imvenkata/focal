# Focal AI Implementation Plan v2.0 (Pure LLM-Based)

## Executive Summary

This plan replaces rule-based heuristics with genuine AI powered by Large Language Models. Every "AI" feature uses actual machine learning, with cloud LLM APIs as the primary engine and Apple Intelligence as an on-device option for iOS 18.4+.

### Core Principles

1. **No fake AI.** If it's not using an LLM or ML model, it's not called "AI" in this plan.
2. **AI is invisible.** No separate "AI tab" - features integrate into existing Todo & Planner tabs.
3. **AI enhances, not replaces.** Existing workflows stay intact; AI makes them smarter.

---

## Integration Strategy

### Philosophy: AI Should Be Invisible

Following Tiimo, Structured, and Apple's design philosophy - users shouldn't think "I need to use AI." They should just do tasks naturally, and AI helps silently.

```
❌ WRONG: Separate AI Tab
┌─────────────────────────────┐
│ [Todo] [Planner] [AI ✨]    │  ← Extra cognitive load
└─────────────────────────────┘

✅ RIGHT: Integrated AI
┌─────────────────────────────┐
│ [Todo] [Planner]            │  ← Same tabs, AI built-in
│                             │
│ ✨ AI powers everything     │
│    behind the scenes        │
└─────────────────────────────┘
```

### Where AI Features Live

| AI Feature | Integration Point | User Access |
|------------|-------------------|-------------|
| **Natural Language Input** | Quick-add bar (both tabs) | Just type naturally |
| **Voice Input** | Mic button on quick-add | Tap mic icon |
| **Brain Dump** | FAB menu | FAB → "Brain Dump" |
| **Task Breakdown** | Task detail / context menu | Long-press → "Break down" |
| **Schedule Suggestions** | Task creation sheet | "When?" → "AI suggest" |
| **Auto-Reschedule** | Banner overlay on Planner | Appears contextually |
| **Insights** | Inline cards on Planner | Dismissible insight cards |

### Visual Integration Map

```
┌─────────────────────────────────────────────────────────────┐
│                         FOCAL APP                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ✨ "Call mom tomorrow 2pm"                     [🎤] │   │ ← AI Quick Add
│  └─────────────────────────────────────────────────────┘   │   (both tabs)
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │   TODO TAB              │    PLANNER TAB            │   │
│  │                         │                           │   │
│  │   Priority lists        │    Timeline view          │   │
│  │   with AI-parsed        │    with AI banners        │   │
│  │   tasks                 │    & insights             │   │
│  │                         │                           │   │
│  │   [AI: Breakdown]       │    [AI: Reschedule]       │   │ ← Context menus
│  │   on task long-press    │    banner when late       │   │
│  │                         │                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────┐                          ┌───────┐   │
│  │ [Todo] [Planner] │                          │  FAB  │   │
│  └──────────────────┘                          │   +   │   │
│        ↑                                       └───┬───┘   │
│   UNCHANGED                                        │       │
│                                           ┌────────┴─────┐ │
│                                           │  Add Task    │ │
│                                           │  Brain Dump✨│ │ ← FAB menu
│                                           │  Voice 🎤    │ │
│                                           └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Views (SwiftUI)                         │
│  ┌─────────────┬─────────────┬─────────────┬─────────────────┐ │
│  │ BrainDump   │ QuickAdd    │ TaskDetail  │ Insights        │ │
│  │ View        │ View        │ View        │ View            │ │
│  └─────────────┴─────────────┴─────────────┴─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    TaskStore / TodoStore                        │
├─────────────────────────────────────────────────────────────────┤
│                       AICoordinator                             │
│         (Orchestrates all AI features, manages state)           │
├─────────────────────────────────────────────────────────────────┤
│                        LLMService                               │
│  ┌─────────────┬─────────────┬─────────────┬─────────────────┐ │
│  │ OpenAI      │ Anthropic   │ Google      │ Apple           │ │
│  │ GPT-4o-mini │ Claude      │ Gemini      │ Intelligence    │ │
│  │             │ Haiku       │ Flash       │ (iOS 18.4+)     │ │
│  └─────────────┴─────────────┴─────────────┴─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    PromptTemplates                              │
│         (Structured prompts for each AI feature)                │
├─────────────────────────────────────────────────────────────────┤
│              SwiftData (Persistence) + Keychain (API Keys)      │
└─────────────────────────────────────────────────────────────────┘
```

---

## LLM Provider Comparison

| Provider | Model | Input/1M | Output/1M | Speed | Recommendation |
|----------|-------|----------|-----------|-------|----------------|
| **Google** | gemini-2.0-flash | $0.10 | $0.40 | Very Fast | **Default choice** |
| **OpenAI** | gpt-4o-mini | $0.15 | $0.60 | Fast | Good alternative |
| **Anthropic** | claude-3-5-haiku | $0.80 | $4.00 | Fast | Best for complex reasoning |
| **Apple** | On-device | Free | Free | Medium | Privacy-first, iOS 18.4+ |

**Cost estimate**: ~300 tokens per request × 50 requests/day = 15K tokens/day = **~$0.006/day** with Gemini

---

## File Structure

```
Focal/
├── Services/
│   └── AI/
│       ├── LLMService.swift           # Core LLM API client
│       ├── LLMProvider.swift          # Provider enum & configs
│       ├── LLMError.swift             # Error types
│       ├── PromptTemplates.swift      # All prompt templates
│       ├── AICoordinator.swift        # Orchestration layer
│       ├── ResponseParsers.swift      # JSON response parsing
│       └── AICache.swift              # Response caching
├── Models/
│   └── AI/
│       ├── ParsedTask.swift           # LLM-parsed task
│       ├── AITaskSuggestion.swift     # Suggestions with confidence
│       ├── OrganizedPlan.swift        # Brain dump output
│       ├── ScheduleSuggestion.swift   # Time slot suggestions
│       └── AIInsight.swift            # Generated insights
├── Views/
│   └── AI/
│       ├── AIOnboardingView.swift     # API key setup
│       ├── BrainDumpView.swift        # Brain dump input
│       ├── BrainDumpResultView.swift  # Organized results
│       ├── AIQuickAddBar.swift        # Natural language input
│       ├── TaskBreakdownSheet.swift   # Subtask generation
│       ├── RescheduleSheet.swift      # AI rescheduling
│       └── AIInsightsView.swift       # AI-generated insights
└── Utilities/
    └── KeychainManager.swift          # Secure API key storage
```

---

## Phase 0: Foundation (Week 1)

### 0.1 LLM Service Core

**Goal**: Create robust, provider-agnostic LLM client

**Files to Create**:
- `Focal/Services/AI/LLMProvider.swift`
- `Focal/Services/AI/LLMService.swift`
- `Focal/Services/AI/LLMError.swift`
- `Focal/Utilities/KeychainManager.swift`

---

#### LLMProvider.swift

```swift
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
                return true // Will add proper check
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
```

---

#### LLMError.swift

```swift
import Foundation

enum LLMError: Error, LocalizedError {
    case notConfigured
    case invalidAPIKey
    case networkError(Error)
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(statusCode: Int, message: String)
    case invalidResponse
    case parsingFailed(String)
    case providerUnavailable
    case contextTooLong
    case contentFiltered
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AI is not configured. Please add your API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your key in Settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited(let retry):
            if let seconds = retry {
                return "Too many requests. Please wait \(Int(seconds)) seconds."
            }
            return "Too many requests. Please try again later."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .invalidResponse:
            return "Received invalid response from AI."
        case .parsingFailed(let detail):
            return "Failed to understand AI response: \(detail)"
        case .providerUnavailable:
            return "AI provider is currently unavailable."
        case .contextTooLong:
            return "Input is too long. Please shorten your text."
        case .contentFiltered:
            return "Content was filtered. Please rephrase."
        case .quotaExceeded:
            return "API quota exceeded. Check your billing."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .rateLimited, .serverError, .networkError, .providerUnavailable:
            return true
        default:
            return false
        }
    }
}
```

---

#### LLMService.swift

```swift
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

    @available(iOS 18.4, *)
    private func callAppleIntelligence(prompt: String, system: String?) async throws -> String {
        // Apple Intelligence integration
        // Uses FoundationModels framework
        #if canImport(FoundationModels)
        import FoundationModels

        let session = LanguageModelSession()
        let fullPrompt = [system, prompt].compactMap { $0 }.joined(separator: "\n\n")
        let response = try await session.respond(to: fullPrompt)
        return response.content
        #else
        throw LLMError.providerUnavailable
        #endif
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

    private func extractJSON(from text: String) -> String {
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
```

---

#### KeychainManager.swift

```swift
import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.focal.app"

    private init() {}

    func saveAPIKey(_ key: String, for provider: LLMProvider) {
        let account = "api_key_\(provider.rawValue)"

        // Delete existing
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func getAPIKey(for provider: LLMProvider) -> String? {
        let account = "api_key_\(provider.rawValue)"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }

    func deleteAPIKey(for provider: LLMProvider) {
        let account = "api_key_\(provider.rawValue)"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

---

## Phase 1: Core AI Features (Weeks 2-3)

### 1.1 Prompt Templates

All AI features use structured prompts for consistent, reliable outputs.

**File**: `Focal/Services/AI/PromptTemplates.swift`

```swift
import Foundation

enum PromptTemplates {

    // MARK: - System Prompts

    static let taskParsingSystem = """
    You are a task parsing assistant for a productivity app.
    Extract structured task information from natural language.
    Always respond with valid JSON only, no explanations.
    Use ISO 8601 format for dates (YYYY-MM-DD).
    Use 24-hour format for times (HH:mm).
    Today's date is \(ISO8601DateFormatter().string(from: Date())).
    """

    static let brainDumpSystem = """
    You are a productivity assistant that helps organize scattered thoughts into actionable tasks.
    Parse the user's brain dump and create structured, prioritized tasks.
    Always respond with valid JSON only.
    Today's date is \(ISO8601DateFormatter().string(from: Date())).
    """

    static let scheduleSystem = """
    You are a scheduling assistant that finds optimal time slots for tasks.
    Consider energy levels, existing commitments, and task requirements.
    Always respond with valid JSON only.
    """

    static let insightSystem = """
    You are an analytics assistant that identifies patterns and provides actionable insights.
    Be encouraging but honest. Focus on specific, actionable recommendations.
    Always respond with valid JSON only.
    """

    // MARK: - Task Parsing

    static func parseTask(input: String) -> String {
        """
        Parse this natural language input into a structured task:

        "\(input)"

        Return JSON in this exact format:
        {
            "title": "clean task title without date/time",
            "date": "YYYY-MM-DD or null if not specified",
            "time": "HH:mm or null if not specified",
            "duration_minutes": estimated minutes or null,
            "energy_level": 0-4 (0=restful, 4=intense) or null,
            "icon": "single emoji that represents this task",
            "color": "coral|sage|sky|lavender|amber|rose|slate" or null,
            "is_recurring": true/false,
            "recurrence": "daily|weekly|weekdays|weekends" or null,
            "confidence": 0.0-1.0 how confident you are in the parsing
        }
        """
    }

    // MARK: - Brain Dump

    static func organizeBrainDump(input: String, existingCategories: [String] = []) -> String {
        """
        The user has done a brain dump of everything on their mind:

        "\(input)"

        Organize this into actionable tasks. For each item:
        1. Create a clear, actionable task title
        2. Identify any dates, times, or deadlines mentioned
        3. Assign priority based on urgency and importance
        4. Group related items together
        5. Suggest an icon and color

        Return JSON:
        {
            "tasks": [
                {
                    "title": "actionable task title",
                    "original_text": "the original fragment this came from",
                    "date": "YYYY-MM-DD or null",
                    "time": "HH:mm or null",
                    "duration_minutes": estimated or null,
                    "priority": "high|medium|low|none",
                    "energy_level": 0-4,
                    "icon": "emoji",
                    "color": "coral|sage|sky|lavender|amber|rose|slate",
                    "category": "work|personal|health|errands|social|other"
                }
            ],
            "summary": "brief summary of what was captured",
            "warnings": ["any concerns about overload, conflicts, etc"]
        }
        """
    }

    // MARK: - Task Breakdown

    static func breakdownTask(task: String, context: String? = nil) -> String {
        """
        Break down this task into actionable subtasks:

        Task: "\(task)"
        \(context.map { "Additional context: \($0)" } ?? "")

        Create 3-7 specific, actionable subtasks. Each should be:
        - Concrete and specific (not vague)
        - Completable in one session
        - Properly sequenced

        Return JSON:
        {
            "subtasks": [
                {
                    "title": "specific subtask",
                    "duration_minutes": estimated time,
                    "order": 1-based order,
                    "is_optional": true/false
                }
            ],
            "total_duration_minutes": sum of all subtasks,
            "notes": "any helpful tips or considerations"
        }
        """
    }

    // MARK: - Schedule Optimization

    static func suggestTimeSlots(
        task: String,
        duration: Int,
        energyLevel: Int,
        existingTasks: [String],
        userPatterns: String
    ) -> String {
        """
        Find the best time slots for this task:

        Task: "\(task)"
        Duration: \(duration) minutes
        Energy required: \(energyLevel)/4

        Already scheduled today:
        \(existingTasks.joined(separator: "\n"))

        User patterns:
        \(userPatterns)

        Suggest 3 optimal time slots. Consider:
        - Energy matching (high energy tasks at peak energy times)
        - Avoiding conflicts with existing tasks
        - Buffer time between tasks
        - User's historical preferences

        Return JSON:
        {
            "suggestions": [
                {
                    "start_time": "HH:mm",
                    "end_time": "HH:mm",
                    "score": 0.0-1.0,
                    "reason": "why this is a good slot"
                }
            ],
            "best_recommendation": "which slot is best and why"
        }
        """
    }

    // MARK: - Rescheduling

    static func suggestReschedule(
        situation: String,
        affectedTasks: [String],
        remainingTime: String
    ) -> String {
        """
        The user's schedule has been disrupted:

        Situation: \(situation)

        Affected tasks:
        \(affectedTasks.joined(separator: "\n"))

        Remaining time today: \(remainingTime)

        Suggest how to adjust the schedule. Options include:
        - Shift tasks later
        - Move tasks to tomorrow
        - Shorten task durations
        - Skip low-priority tasks

        Return JSON:
        {
            "strategy": "shift|compress|skip|move_tomorrow|hybrid",
            "adjustments": [
                {
                    "task_title": "task name",
                    "action": "move|shorten|skip|keep",
                    "new_time": "HH:mm or null",
                    "new_duration_minutes": new duration or null,
                    "reason": "why this adjustment"
                }
            ],
            "summary": "brief explanation of the new plan",
            "trade_offs": ["what the user is giving up"]
        }
        """
    }

    // MARK: - Insights

    static func generateInsights(
        completionData: String,
        patterns: String,
        recentActivity: String
    ) -> String {
        """
        Analyze this productivity data and generate insights:

        Completion rates:
        \(completionData)

        Observed patterns:
        \(patterns)

        Recent activity:
        \(recentActivity)

        Generate 3-5 actionable insights. Focus on:
        - Productivity patterns (best times, best days)
        - Areas for improvement
        - Positive trends to reinforce
        - Specific, actionable recommendations

        Return JSON:
        {
            "insights": [
                {
                    "type": "productivity|timing|estimation|streak|warning|recommendation",
                    "title": "short insight title",
                    "description": "detailed explanation",
                    "action": "specific action the user can take",
                    "priority": "high|medium|low"
                }
            ],
            "overall_summary": "brief overall assessment"
        }
        """
    }
}
```

---

### 1.2 AI Coordinator

**File**: `Focal/Services/AI/AICoordinator.swift`

```swift
import Foundation
import SwiftUI

@Observable
final class AICoordinator {

    // MARK: - Dependencies

    private let llm: LLMService

    // MARK: - State

    var isConfigured: Bool { llm.isConfigured }
    var isLoading: Bool { llm.isLoading }
    var currentProvider: LLMProvider { llm.currentProvider }
    var lastError: LLMError?

    // MARK: - Init

    init(llmService: LLMService = LLMService()) {
        self.llm = llmService
    }

    // MARK: - Configuration

    func configure(provider: LLMProvider, apiKey: String) {
        llm.configure(provider: provider, apiKey: apiKey)
    }

    // MARK: - Task Parsing

    /// Parse natural language into a structured task
    func parseTask(_ input: String) async throws -> ParsedTask {
        let prompt = PromptTemplates.parseTask(input: input)

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.taskParsingSystem,
            responseType: ParsedTask.self
        )
    }

    // MARK: - Brain Dump

    /// Organize brain dump into structured tasks
    func organizeBrainDump(_ input: String) async throws -> OrganizedBrainDump {
        let prompt = PromptTemplates.organizeBrainDump(input: input)

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.brainDumpSystem,
            responseType: OrganizedBrainDump.self
        )
    }

    // MARK: - Task Breakdown

    /// Break complex task into subtasks
    func breakdownTask(_ task: String, context: String? = nil) async throws -> TaskBreakdown {
        let prompt = PromptTemplates.breakdownTask(task: task, context: context)

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.taskParsingSystem,
            responseType: TaskBreakdown.self
        )
    }

    // MARK: - Scheduling

    /// Get AI-suggested time slots
    func suggestTimeSlots(
        for task: String,
        duration: Int,
        energyLevel: Int,
        existingTasks: [TaskItem],
        date: Date = Date()
    ) async throws -> ScheduleSuggestions {
        let existingFormatted = existingTasks.map { task in
            "\(task.startTime.formatted(date: .omitted, time: .shortened)) - \(task.endTime.formatted(date: .omitted, time: .shortened)): \(task.title)"
        }

        // TODO: Get real user patterns from PatternStore
        let patterns = "Typically most productive 9-11am and 2-4pm"

        let prompt = PromptTemplates.suggestTimeSlots(
            task: task,
            duration: duration,
            energyLevel: energyLevel,
            existingTasks: existingFormatted,
            userPatterns: patterns
        )

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.scheduleSystem,
            responseType: ScheduleSuggestions.self
        )
    }

    // MARK: - Rescheduling

    /// Get rescheduling suggestions when plans change
    func suggestReschedule(
        situation: String,
        affectedTasks: [TaskItem],
        remainingHours: Double
    ) async throws -> RescheduleSuggestion {
        let tasksFormatted = affectedTasks.map { task in
            "\(task.startTime.formatted(date: .omitted, time: .shortened)): \(task.title) (\(task.durationFormatted))"
        }

        let prompt = PromptTemplates.suggestReschedule(
            situation: situation,
            affectedTasks: tasksFormatted,
            remainingTime: "\(Int(remainingHours)) hours"
        )

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.scheduleSystem,
            responseType: RescheduleSuggestion.self
        )
    }

    // MARK: - Insights

    /// Generate AI insights from user data
    func generateInsights(
        completionRate: Double,
        tasksCompleted: Int,
        tasksScheduled: Int,
        averageDuration: TimeInterval,
        topCategories: [String]
    ) async throws -> AIInsights {
        let completionData = """
        Completion rate: \(Int(completionRate * 100))%
        Tasks completed this week: \(tasksCompleted)
        Tasks scheduled: \(tasksScheduled)
        Average task duration: \(Int(averageDuration / 60)) minutes
        """

        let patterns = "Top categories: \(topCategories.joined(separator: ", "))"

        let recentActivity = "Active user with regular task scheduling"

        let prompt = PromptTemplates.generateInsights(
            completionData: completionData,
            patterns: patterns,
            recentActivity: recentActivity
        )

        return try await llm.completeJSON(
            prompt: prompt,
            systemPrompt: PromptTemplates.insightSystem,
            responseType: AIInsights.self
        )
    }
}
```

---

### 1.3 AI Response Models

**File**: `Focal/Models/AI/AIModels.swift`

```swift
import Foundation

// MARK: - Parsed Task

struct ParsedTask: Codable {
    let title: String
    let date: String?
    let time: String?
    let durationMinutes: Int?
    let energyLevel: Int?
    let icon: String?
    let color: String?
    let isRecurring: Bool?
    let recurrence: String?
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case title, date, time, icon, color, recurrence, confidence
        case durationMinutes = "duration_minutes"
        case energyLevel = "energy_level"
        case isRecurring = "is_recurring"
    }

    /// Convert to TaskItem for creation
    func toTaskItem() -> TaskItem {
        let task = TaskItem(
            title: title,
            startTime: resolvedStartTime ?? Date(),
            duration: TimeInterval((durationMinutes ?? 30) * 60)
        )

        task.icon = icon ?? "📌"
        task.colorName = color ?? "sky"
        task.energyLevel = energyLevel ?? 2

        return task
    }

    /// Convert to TodoItem for creation
    func toTodoItem() -> TodoItem {
        let todo = TodoItem(title: title)

        todo.icon = icon ?? "📌"
        todo.colorName = color ?? "sky"
        todo.dueDate = resolvedDate
        todo.hasDueTime = time != nil

        if let time, let dueDate = todo.dueDate {
            todo.dueTime = resolvedTime(on: dueDate)
        }

        return todo
    }

    private var resolvedDate: Date? {
        guard let date else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: date)
    }

    private var resolvedStartTime: Date? {
        guard let date = resolvedDate else { return nil }
        guard let time else { return date }
        return resolvedTime(on: date)
    }

    private func resolvedTime(on date: Date) -> Date? {
        guard let time else { return nil }
        let components = time.split(separator: ":").compactMap { Int($0) }
        guard components.count >= 2 else { return nil }

        return Calendar.current.date(
            bySettingHour: components[0],
            minute: components[1],
            second: 0,
            of: date
        )
    }
}

// MARK: - Brain Dump

struct OrganizedBrainDump: Codable {
    let tasks: [BrainDumpTask]
    let summary: String
    let warnings: [String]?
}

struct BrainDumpTask: Codable, Identifiable {
    var id = UUID()
    let title: String
    let originalText: String?
    let date: String?
    let time: String?
    let durationMinutes: Int?
    let priority: String
    let energyLevel: Int?
    let icon: String
    let color: String
    let category: String

    var isSelected: Bool = true  // For UI selection

    enum CodingKeys: String, CodingKey {
        case title, date, time, priority, icon, color, category
        case originalText = "original_text"
        case durationMinutes = "duration_minutes"
        case energyLevel = "energy_level"
    }

    func toTodoItem() -> TodoItem {
        let todo = TodoItem(title: title)
        todo.icon = icon
        todo.colorName = color
        todo.priority = priority.uppercased()

        if let date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            todo.dueDate = formatter.date(from: date)
        }

        return todo
    }
}

// MARK: - Task Breakdown

struct TaskBreakdown: Codable {
    let subtasks: [GeneratedSubtask]
    let totalDurationMinutes: Int
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case subtasks, notes
        case totalDurationMinutes = "total_duration_minutes"
    }
}

struct GeneratedSubtask: Codable, Identifiable {
    var id = UUID()
    let title: String
    let durationMinutes: Int
    let order: Int
    let isOptional: Bool?

    enum CodingKeys: String, CodingKey {
        case title, order
        case durationMinutes = "duration_minutes"
        case isOptional = "is_optional"
    }
}

// MARK: - Schedule Suggestions

struct ScheduleSuggestions: Codable {
    let suggestions: [TimeSlotSuggestion]
    let bestRecommendation: String

    enum CodingKeys: String, CodingKey {
        case suggestions
        case bestRecommendation = "best_recommendation"
    }
}

struct TimeSlotSuggestion: Codable, Identifiable {
    var id = UUID()
    let startTime: String
    let endTime: String
    let score: Double
    let reason: String

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case score, reason
    }
}

// MARK: - Reschedule

struct RescheduleSuggestion: Codable {
    let strategy: String
    let adjustments: [TaskAdjustment]
    let summary: String
    let tradeOffs: [String]?

    enum CodingKeys: String, CodingKey {
        case strategy, adjustments, summary
        case tradeOffs = "trade_offs"
    }
}

struct TaskAdjustment: Codable, Identifiable {
    var id = UUID()
    let taskTitle: String
    let action: String
    let newTime: String?
    let newDurationMinutes: Int?
    let reason: String

    enum CodingKeys: String, CodingKey {
        case action, reason
        case taskTitle = "task_title"
        case newTime = "new_time"
        case newDurationMinutes = "new_duration_minutes"
    }
}

// MARK: - Insights

struct AIInsights: Codable {
    let insights: [AIInsight]
    let overallSummary: String

    enum CodingKeys: String, CodingKey {
        case insights
        case overallSummary = "overall_summary"
    }
}

struct AIInsight: Codable, Identifiable {
    var id = UUID()
    let type: String
    let title: String
    let description: String
    let action: String?
    let priority: String

    enum CodingKeys: String, CodingKey {
        case type, title, description, action, priority
    }

    var icon: String {
        switch type {
        case "productivity": return "chart.line.uptrend.xyaxis"
        case "timing": return "clock.fill"
        case "estimation": return "timer"
        case "streak": return "flame.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "recommendation": return "lightbulb.fill"
        default: return "sparkles"
        }
    }
}
```

---

---

## Phase 2: AI-Powered UI (Weeks 3-4)

### 2.1 AI Onboarding & Settings

**File**: `Focal/Views/AI/AIOnboardingView.swift`

```swift
import SwiftUI

struct AIOnboardingView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProvider: LLMProvider = .gemini
    @State private var apiKey: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isValidated: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xxl) {
                    // Header
                    VStack(spacing: DS.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Enable AI Features")
                            .font(.title.weight(.bold))

                        Text("Connect an AI provider to unlock intelligent task parsing, smart scheduling, and personalized insights.")
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DS.Spacing.xl)

                    // Provider Selection
                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        Text("Choose Provider")
                            .font(.headline)

                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            ProviderCard(
                                provider: provider,
                                isSelected: selectedProvider == provider,
                                onSelect: {
                                    selectedProvider = provider
                                    apiKey = ""
                                    validationError = nil
                                    isValidated = false
                                }
                            )
                        }
                    }
                    .padding(.horizontal)

                    // API Key Input
                    if selectedProvider.requiresAPIKey {
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("API Key")
                                .font(.headline)

                            SecureField(selectedProvider.apiKeyPlaceholder, text: $apiKey)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(DS.Colors.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

                            Text(selectedProvider.setupInstructions)
                                .font(.caption)
                                .foregroundStyle(DS.Colors.textMuted)

                            if let error = validationError {
                                Label(error, systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.error)
                            }

                            if isValidated {
                                Label("API key validated successfully", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.success)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: DS.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: DS.Spacing.md) {
                    Button {
                        Task { await validateAndSave() }
                    } label: {
                        HStack {
                            if isValidating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isValidated ? "Enable AI" : "Validate & Enable")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(canSubmit ? DS.Colors.primary : DS.Colors.textMuted)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .disabled(!canSubmit || isValidating)
                }
                .padding()
                .background(DS.Colors.cardBackground)
            }
        }
    }

    private var canSubmit: Bool {
        if selectedProvider == .apple {
            return selectedProvider.isAvailable
        }
        return !apiKey.isEmpty
    }

    private func validateAndSave() async {
        isValidating = true
        validationError = nil

        do {
            // Test the API key with a simple request
            ai.configure(provider: selectedProvider, apiKey: apiKey)

            let _ = try await ai.parseTask("test task tomorrow")

            isValidated = true
            HapticManager.shared.notification(.success)

            // Dismiss after short delay
            try? await Task.sleep(for: .seconds(0.5))
            dismiss()

        } catch let error as LLMError {
            validationError = error.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            validationError = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isValidating = false
    }
}

struct ProviderCard: View {
    let provider: LLMProvider
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: providerIcon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DS.Colors.textPrimary)

                    Text(provider.modelName)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()

                if !provider.isAvailable {
                    Text("Unavailable")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DS.Colors.primary)
                }
            }
            .padding()
            .background(isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(isSelected ? DS.Colors.primary : .clear, lineWidth: 2)
            )
        }
        .disabled(!provider.isAvailable)
        .opacity(provider.isAvailable ? 1 : 0.5)
    }

    private var providerIcon: String {
        switch provider {
        case .gemini: return "g.circle.fill"
        case .openAI: return "brain.head.profile"
        case .anthropic: return "sparkles.rectangle.stack"
        case .apple: return "apple.logo"
        }
    }
}
```

---

### 2.2 AI Quick Add Bar

**File**: `Focal/Views/AI/AIQuickAddBar.swift`

```swift
import SwiftUI

struct AIQuickAddBar: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore
    @Environment(TodoStore.self) private var todoStore

    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var parsedTask: ParsedTask?
    @State private var showParsedPreview: Bool = false
    @State private var error: String?

    @FocusState private var isFocused: Bool

    enum AddDestination {
        case schedule // Add to timeline with time
        case todo     // Add to todo list
    }

    var body: some View {
        VStack(spacing: 0) {
            // Error banner
            if let error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                    Spacer()
                    Button {
                        self.error = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .font(.caption)
                .foregroundStyle(DS.Colors.error)
                .padding(DS.Spacing.sm)
                .background(DS.Colors.error.opacity(0.1))
            }

            // Parsed preview
            if showParsedPreview, let parsed = parsedTask {
                ParsedTaskPreview(
                    task: parsed,
                    onAddToSchedule: { addToSchedule(parsed) },
                    onAddToTodo: { addToTodo(parsed) },
                    onEdit: { showParsedPreview = false },
                    onDismiss: {
                        showParsedPreview = false
                        parsedTask = nil
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Input bar
            HStack(spacing: DS.Spacing.sm) {
                // AI indicator
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Text field
                TextField("Add task with AI... \"Gym tomorrow 7am\"", text: $inputText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { Task { await processInput() } }

                // Submit button
                if !inputText.isEmpty {
                    Button {
                        Task { await processInput() }
                    } label: {
                        Group {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                            }
                        }
                        .foregroundStyle(DS.Colors.primary)
                    }
                    .disabled(isProcessing)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
    }

    private func processInput() async {
        guard !inputText.isEmpty else { return }
        guard ai.isConfigured else {
            error = "AI not configured. Go to Settings to set up."
            return
        }

        isProcessing = true
        error = nil
        HapticManager.shared.impact(.medium)

        do {
            let parsed = try await ai.parseTask(inputText)
            self.parsedTask = parsed

            withAnimation(DS.Animation.spring) {
                showParsedPreview = true
            }

            HapticManager.shared.notification(.success)

        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isProcessing = false
    }

    private func addToSchedule(_ parsed: ParsedTask) {
        let task = parsed.toTaskItem()
        taskStore.addTask(task)

        // Reset state
        inputText = ""
        parsedTask = nil
        showParsedPreview = false
        isFocused = false

        HapticManager.shared.notification(.success)
    }

    private func addToTodo(_ parsed: ParsedTask) {
        let todo = parsed.toTodoItem()
        todoStore.addTodo(todo)

        // Reset state
        inputText = ""
        parsedTask = nil
        showParsedPreview = false
        isFocused = false

        HapticManager.shared.notification(.success)
    }
}

struct ParsedTaskPreview: View {
    let task: ParsedTask
    let onAddToSchedule: () -> Void
    let onAddToTodo: () -> Void
    let onEdit: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Header with dismiss
            HStack {
                Text("AI parsed your task")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DS.Colors.textMuted)
                }
            }

            // Task preview card
            HStack(spacing: DS.Spacing.md) {
                Text(task.icon ?? "📌")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline.weight(.medium))

                    HStack(spacing: DS.Spacing.sm) {
                        if let date = task.date {
                            Label(date, systemImage: "calendar")
                        }
                        if let time = task.time {
                            Label(time, systemImage: "clock")
                        }
                        if let duration = task.durationMinutes {
                            Label("\(duration)m", systemImage: "timer")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer()

                // Confidence indicator
                ConfidenceIndicator(confidence: task.confidence)
            }
            .padding()
            .background(DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

            // Action buttons
            HStack(spacing: DS.Spacing.sm) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)

                Spacer()

                if task.date != nil && task.time != nil {
                    Button(action: onAddToSchedule) {
                        Label("Add to Schedule", systemImage: "calendar.badge.plus")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button(action: onAddToTodo) {
                    Label("Add to Todos", systemImage: "checklist")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(task.time == nil ? .borderedProminent : .bordered)
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
    }
}

struct ConfidenceIndicator: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < filledDots ? DS.Colors.success : DS.Colors.textMuted.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var filledDots: Int {
        if confidence >= 0.9 { return 3 }
        if confidence >= 0.7 { return 2 }
        return 1
    }
}
```

---

### 2.3 Brain Dump View

**File**: `Focal/Views/AI/BrainDumpView.swift`

```swift
import SwiftUI

struct BrainDumpView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TodoStore.self) private var todoStore
    @Environment(\.dismiss) private var dismiss

    @State private var rawText: String = ""
    @State private var isProcessing: Bool = false
    @State private var result: OrganizedBrainDump?
    @State private var error: String?
    @State private var showResults: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showResults, let result {
                    BrainDumpResultView(
                        result: result,
                        onAddSelected: addSelectedTasks,
                        onBack: { showResults = false }
                    )
                } else {
                    inputView
                }
            }
            .navigationTitle("Brain Dump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var inputView: some View {
        VStack(spacing: DS.Spacing.xl) {
            // Header
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Dump everything on your mind")
                    .font(.headline)

                Text("Type freely. AI will organize it into tasks.")
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(.top, DS.Spacing.xl)

            // Text input
            ZStack(alignment: .topLeading) {
                TextEditor(text: $rawText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(DS.Spacing.md)

                if rawText.isEmpty {
                    Text("Buy groceries, call mom about weekend plans, finish the quarterly report by Friday, schedule dentist appointment, renew gym membership, plan birthday party for Sarah...")
                        .font(.body)
                        .foregroundStyle(DS.Colors.textMuted)
                        .padding(DS.Spacing.md)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxHeight: .infinity)
            .background(DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .padding(.horizontal)

            // Error message
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(DS.Colors.error)
                    .padding(.horizontal)
            }

            // Action button
            Button {
                Task { await processBrainDump() }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isProcessing ? "Organizing..." : "Organize with AI")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: DS.Sizes.buttonHeight)
                .background(rawText.isEmpty || isProcessing ? DS.Colors.textMuted : DS.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            }
            .disabled(rawText.isEmpty || isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func processBrainDump() async {
        guard ai.isConfigured else {
            error = "AI not configured. Go to Settings to set up."
            return
        }

        isProcessing = true
        error = nil
        HapticManager.shared.impact(.medium)

        do {
            result = try await ai.organizeBrainDump(rawText)

            withAnimation(DS.Animation.spring) {
                showResults = true
            }

            HapticManager.shared.notification(.success)

        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isProcessing = false
    }

    private func addSelectedTasks(_ tasks: [BrainDumpTask]) {
        for task in tasks {
            let todo = task.toTodoItem()
            todoStore.addTodo(todo)
        }

        HapticManager.shared.notification(.success)
        dismiss()
    }
}

struct BrainDumpResultView: View {
    let result: OrganizedBrainDump
    let onAddSelected: ([BrainDumpTask]) -> Void
    let onBack: () -> Void

    @State private var tasks: [BrainDumpTask]
    @State private var selectedIds: Set<UUID> = []

    init(result: OrganizedBrainDump, onAddSelected: @escaping ([BrainDumpTask]) -> Void, onBack: @escaping () -> Void) {
        self.result = result
        self.onAddSelected = onAddSelected
        self.onBack = onBack
        self._tasks = State(initialValue: result.tasks)
        self._selectedIds = State(initialValue: Set(result.tasks.map { $0.id }))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            VStack(spacing: DS.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(result.tasks.count) tasks found")
                            .font(.title3.weight(.semibold))

                        Text(result.summary)
                            .font(.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }

                    Spacer()

                    Button(selectedIds.count == tasks.count ? "Deselect All" : "Select All") {
                        if selectedIds.count == tasks.count {
                            selectedIds.removeAll()
                        } else {
                            selectedIds = Set(tasks.map { $0.id })
                        }
                    }
                    .font(.caption)
                }

                // Warnings
                if let warnings = result.warnings, !warnings.isEmpty {
                    ForEach(warnings, id: \.self) { warning in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(DS.Colors.warning)
                            Text(warning)
                                .font(.caption)
                        }
                        .padding(DS.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DS.Colors.warning.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                }
            }
            .padding()

            Divider()

            // Task list by priority
            ScrollView {
                LazyVStack(spacing: DS.Spacing.md) {
                    ForEach(["high", "medium", "low", "none"], id: \.self) { priority in
                        let priorityTasks = tasks.filter { $0.priority == priority }

                        if !priorityTasks.isEmpty {
                            PrioritySection(
                                priority: priority,
                                tasks: priorityTasks,
                                selectedIds: $selectedIds
                            )
                        }
                    }
                }
                .padding()
            }

            // Bottom action bar
            VStack(spacing: DS.Spacing.sm) {
                Button {
                    let selected = tasks.filter { selectedIds.contains($0.id) }
                    onAddSelected(selected)
                } label: {
                    Text("Add \(selectedIds.count) Tasks")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(selectedIds.isEmpty ? DS.Colors.textMuted : DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
                .disabled(selectedIds.isEmpty)

                Button("Back to Edit", action: onBack)
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.primary)
            }
            .padding()
            .background(DS.Colors.cardBackground)
        }
    }
}

struct PrioritySection: View {
    let priority: String
    let tasks: [BrainDumpTask]
    @Binding var selectedIds: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: priorityIcon)
                    .foregroundStyle(priorityColor)
                Text(priority.capitalized + " Priority")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            ForEach(tasks) { task in
                BrainDumpTaskRow(
                    task: task,
                    isSelected: selectedIds.contains(task.id),
                    onToggle: {
                        if selectedIds.contains(task.id) {
                            selectedIds.remove(task.id)
                        } else {
                            selectedIds.insert(task.id)
                        }
                    }
                )
            }
        }
    }

    private var priorityIcon: String {
        switch priority {
        case "high": return "exclamationmark.circle.fill"
        case "medium": return "arrow.up.circle.fill"
        case "low": return "arrow.down.circle.fill"
        default: return "minus.circle.fill"
        }
    }

    private var priorityColor: Color {
        switch priority {
        case "high": return DS.Colors.error
        case "medium": return DS.Colors.warning
        case "low": return DS.Colors.info
        default: return DS.Colors.textMuted
        }
    }
}

struct BrainDumpTaskRow: View {
    let task: BrainDumpTask
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DS.Spacing.md) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? DS.Colors.primary : DS.Colors.textMuted)

                // Icon
                Text(task.icon)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline)
                        .foregroundStyle(DS.Colors.textPrimary)

                    HStack(spacing: DS.Spacing.sm) {
                        if let date = task.date {
                            Text(date)
                        }
                        if let duration = task.durationMinutes {
                            Text("\(duration)m")
                        }
                        Text(task.category)
                    }
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()
            }
            .padding(DS.Spacing.md)
            .background(isSelected ? DS.Colors.primary.opacity(0.05) : DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}
```

---

## Phase 3: Advanced AI Features (Weeks 5-6)

### 3.1 Task Breakdown

**File**: `Focal/Views/AI/TaskBreakdownSheet.swift`

```swift
import SwiftUI

struct TaskBreakdownSheet: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(\.dismiss) private var dismiss

    let taskTitle: String
    let onAccept: ([Subtask]) -> Void

    @State private var breakdown: TaskBreakdown?
    @State private var isLoading: Bool = true
    @State private var error: String?
    @State private var editedSubtasks: [GeneratedSubtask] = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error {
                    errorView(error)
                } else if breakdown != nil {
                    resultView
                }
            }
            .navigationTitle("Break Down Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await loadBreakdown()
        }
    }

    private var loadingView: some View {
        VStack(spacing: DS.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("AI is breaking down your task...")
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.error)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadBreakdown() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var resultView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Original task
                    VStack(spacing: DS.Spacing.sm) {
                        Text("Breaking down:")
                            .font(.caption)
                            .foregroundStyle(DS.Colors.textMuted)

                        Text(taskTitle)
                            .font(.headline)
                    }
                    .padding()

                    // Total time estimate
                    if let breakdown {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(DS.Colors.primary)
                            Text("Total: \(breakdown.totalDurationMinutes) minutes")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(DS.Spacing.md)
                        .background(DS.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }

                    // Subtasks
                    VStack(spacing: DS.Spacing.sm) {
                        ForEach(Array(editedSubtasks.enumerated()), id: \.element.id) { index, subtask in
                            SubtaskRow(
                                subtask: subtask,
                                index: index + 1
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Notes
                    if let notes = breakdown?.notes {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Label("AI Notes", systemImage: "lightbulb.fill")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(DS.Colors.textMuted)

                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DS.Colors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }

            // Accept button
            VStack {
                Button {
                    acceptBreakdown()
                } label: {
                    Text("Add \(editedSubtasks.count) Subtasks")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
            }
            .padding()
            .background(DS.Colors.cardBackground)
        }
    }

    private func loadBreakdown() async {
        isLoading = true
        error = nil

        do {
            breakdown = try await ai.breakdownTask(taskTitle)
            editedSubtasks = breakdown?.subtasks ?? []
            HapticManager.shared.notification(.success)
        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isLoading = false
    }

    private func acceptBreakdown() {
        let subtasks = editedSubtasks.map { generated in
            Subtask(title: generated.title)
        }
        onAccept(subtasks)
        dismiss()
    }
}

struct SubtaskRow: View {
    let subtask: GeneratedSubtask
    let index: Int

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Text("\(index)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(DS.Colors.primary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(subtask.title)
                    .font(.subheadline)

                Text("\(subtask.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            if subtask.isOptional == true {
                Text("Optional")
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.textMuted)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(Capsule())
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}
```

---

### 3.2 AI Schedule Suggestions

**File**: `Focal/Views/AI/ScheduleSuggestionsSheet.swift`

```swift
import SwiftUI

struct ScheduleSuggestionsSheet: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore
    @Environment(\.dismiss) private var dismiss

    let taskTitle: String
    let duration: TimeInterval
    let energyLevel: Int
    let onSelect: (Date) -> Void

    @State private var suggestions: ScheduleSuggestions?
    @State private var isLoading: Bool = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Finding best times...")
                } else if let error {
                    errorView(error)
                } else if let suggestions {
                    suggestionsView(suggestions)
                }
            }
            .navigationTitle("AI Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await loadSuggestions()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.error)

            Text(message)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadSuggestions() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func suggestionsView(_ suggestions: ScheduleSuggestions) -> some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                // Best recommendation
                VStack(spacing: DS.Spacing.sm) {
                    Label("AI Recommendation", systemImage: "sparkles")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DS.Colors.primary)

                    Text(suggestions.bestRecommendation)
                        .font(.subheadline)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(DS.Colors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))

                // Time slots
                VStack(spacing: DS.Spacing.md) {
                    ForEach(suggestions.suggestions) { slot in
                        TimeSlotCard(slot: slot) {
                            selectSlot(slot)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func loadSuggestions() async {
        isLoading = true
        error = nil

        do {
            suggestions = try await ai.suggestTimeSlots(
                for: taskTitle,
                duration: Int(duration / 60),
                energyLevel: energyLevel,
                existingTasks: taskStore.tasksForSelectedDate
            )
            HapticManager.shared.notification(.success)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isLoading = false
    }

    private func selectSlot(_ slot: TimeSlotSuggestion) {
        // Parse time and create date
        let components = slot.startTime.split(separator: ":").compactMap { Int($0) }
        guard components.count >= 2 else { return }

        let selectedDate = taskStore.selectedDate
        if let date = Calendar.current.date(bySettingHour: components[0], minute: components[1], second: 0, of: selectedDate) {
            onSelect(date)
            dismiss()
        }
    }
}

struct TimeSlotCard: View {
    let slot: TimeSlotSuggestion
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.md) {
                // Time range
                VStack(alignment: .leading) {
                    Text(slot.startTime)
                        .font(.title3.weight(.semibold))
                    Text("to \(slot.endTime)")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()

                // Score indicator
                ScoreIndicator(score: slot.score)

                // Reason
                VStack(alignment: .trailing, spacing: 2) {
                    Text(slot.reason)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
                .frame(maxWidth: 150)

                Image(systemName: "chevron.right")
                    .foregroundStyle(DS.Colors.textMuted)
            }
            .padding()
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
        .buttonStyle(.plain)
    }
}

struct ScoreIndicator: View {
    let score: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(DS.Colors.textMuted.opacity(0.2), lineWidth: 4)

            Circle()
                .trim(from: 0, to: score)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(score * 100))")
                .font(.caption2.weight(.bold))
        }
        .frame(width: 36, height: 36)
    }

    private var scoreColor: Color {
        if score >= 0.8 { return DS.Colors.success }
        if score >= 0.6 { return DS.Colors.warning }
        return DS.Colors.error
    }
}
```

---

## Phase 4: Integration & Polish (Week 7)

### 4.1 Entry Points

Add AI features to existing views:

```swift
// In FloatingTaskInputCard or TodoQuickAddBar
// Replace with AIQuickAddBar when AI is configured

struct SmartInputWrapper: View {
    @Environment(AICoordinator.self) private var ai

    var body: some View {
        if ai.isConfigured {
            AIQuickAddBar()
        } else {
            // Original input with "Enable AI" prompt
            VStack {
                OriginalQuickAddBar()

                Button {
                    // Show AI onboarding
                } label: {
                    Label("Enable AI features", systemImage: "sparkles")
                        .font(.caption)
                }
            }
        }
    }
}
```

### 4.2 Settings Integration

```swift
// Add to Settings view
Section {
    NavigationLink {
        AISettingsView()
    } label: {
        Label("AI Assistant", systemImage: "sparkles")
    }
}
```

### 4.3 App Entry Point

```swift
// In FocalApp.swift
@main
struct FocalApp: App {
    @State private var aiCoordinator = AICoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(aiCoordinator)
        }
    }
}
```

---

## Summary: Files to Create

### New AI Files (12 files)

| Phase | File | Purpose |
|-------|------|---------|
| 0 | `Services/AI/LLMProvider.swift` | Provider enum & config |
| 0 | `Services/AI/LLMService.swift` | Core API client |
| 0 | `Services/AI/LLMError.swift` | Error handling |
| 0 | `Utilities/KeychainManager.swift` | Secure key storage |
| 1 | `Services/AI/PromptTemplates.swift` | All prompts |
| 1 | `Services/AI/AICoordinator.swift` | Orchestration |
| 1 | `Models/AI/AIModels.swift` | Response types |
| 2 | `Views/AI/AIOnboardingView.swift` | API key setup (sheet) |
| 2 | `Views/AI/AIQuickAddBar.swift` | NL task input component |
| 2 | `Views/AI/BrainDumpView.swift` | Brain dump (sheet from FAB) |
| 3 | `Views/AI/TaskBreakdownSheet.swift` | Subtask generation (sheet) |
| 3 | `Views/AI/ScheduleSuggestionsSheet.swift` | Time slot AI (sheet) |
| 3 | `Views/AI/RescheduleBanner.swift` | Contextual reschedule banner |
| 3 | `Views/AI/AIInsightCard.swift` | Inline insight cards |

### Existing Files to Modify (Integration Points)

| File | Modification |
|------|--------------|
| `FocalApp.swift` | Add `AICoordinator` to environment |
| `ContentView.swift` | No change (tabs stay same) |
| `TodoView.swift` | Replace quick-add with `AIQuickAddBar` |
| `PlannerView.swift` | Add `RescheduleBanner`, `AIInsightCard`, `AIQuickAddBar` |
| `FABButton.swift` | Add Brain Dump & Voice options to menu |
| `TaskDetailView.swift` | Add "Break down with AI" action |
| `TaskCardView.swift` | Add AI context menu options |
| `TodoDetailView.swift` | Add "Break down with AI" action |
| `BottomTabBar.swift` | **NO CHANGE** - keep Todo & Planner only |

### Final File Structure

```
Focal/
├── App/
│   ├── FocalApp.swift              ← Add AICoordinator environment
│   └── ContentView.swift           ← UNCHANGED
│
├── Services/
│   ├── AI/                         ← NEW FOLDER
│   │   ├── LLMProvider.swift
│   │   ├── LLMService.swift
│   │   ├── LLMError.swift
│   │   ├── PromptTemplates.swift
│   │   └── AICoordinator.swift
│   ├── RecurringTaskGenerator.swift
│   └── ...existing services...
│
├── Models/
│   ├── AI/                         ← NEW FOLDER
│   │   └── AIModels.swift
│   ├── TaskItem.swift
│   └── ...existing models...
│
├── ViewModels/
│   ├── TaskStore.swift             ← UNCHANGED
│   └── TodoStore.swift             ← UNCHANGED
│
├── Views/
│   ├── AI/                         ← NEW FOLDER (sheets & components)
│   │   ├── AIOnboardingView.swift      (sheet)
│   │   ├── AIQuickAddBar.swift         (component)
│   │   ├── BrainDumpView.swift         (sheet)
│   │   ├── TaskBreakdownSheet.swift    (sheet)
│   │   ├── ScheduleSuggestionsSheet.swift (sheet)
│   │   ├── RescheduleBanner.swift      (component)
│   │   ├── AIInsightCard.swift         (component)
│   │   └── VoiceInputSheet.swift       (sheet)
│   │
│   ├── Todo/
│   │   ├── TodoView.swift          ← MODIFY: add AIQuickAddBar
│   │   └── TodoDetailView.swift    ← MODIFY: add breakdown action
│   │
│   ├── Timeline/
│   │   └── PlannerView.swift       ← MODIFY: add banner, insights, quick-add
│   │
│   ├── Task/
│   │   ├── TaskDetailView.swift    ← MODIFY: add breakdown action
│   │   └── TaskCardView.swift      ← MODIFY: add context menu
│   │
│   ├── Navigation/
│   │   ├── BottomTabBar.swift      ← UNCHANGED (still 2 tabs)
│   │   └── FABButton.swift         ← MODIFY: add Brain Dump option
│   │
│   └── ...other views unchanged...
│
└── Utilities/
    ├── KeychainManager.swift       ← NEW
    ├── DesignSystem.swift          ← UNCHANGED
    └── ...existing utilities...
```

---

## Integration Code Examples

### 1. FocalApp.swift (Add AI Environment)

```swift
import SwiftUI
import SwiftData

@main
struct FocalApp: App {
    // Existing
    @State private var taskStore = TaskStore()
    @State private var todoStore = TodoStore()

    // NEW: AI Coordinator
    @State private var aiCoordinator = AICoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(taskStore)
                .environment(todoStore)
                .environment(aiCoordinator)  // ← ADD THIS
        }
        .modelContainer(for: [TaskItem.self, TodoItem.self])
    }
}
```

### 2. TodoView.swift (Integrate AI Quick Add)

```swift
struct TodoView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TodoStore.self) private var todoStore

    @State private var showAIOnboarding = false

    var body: some View {
        VStack(spacing: 0) {
            // Header (existing)
            TodoHeaderView()

            // Main content (existing)
            TodoListView()

            Divider()

            // MODIFIED: AI-powered quick add OR prompt to enable
            if ai.isConfigured {
                AIQuickAddBar(destination: .todo)
            } else {
                QuickAddWithAIPrompt(onEnableAI: { showAIOnboarding = true })
            }
        }
        .sheet(isPresented: $showAIOnboarding) {
            AIOnboardingView()
        }
    }
}

// Component for when AI is not configured
struct QuickAddWithAIPrompt: View {
    let onEnableAI: () -> Void
    @State private var title = ""

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            // Existing simple input
            HStack {
                TextField("Add a task...", text: $title)
                Button("Add") { /* existing add logic */ }
            }
            .padding()

            // AI enable prompt
            Button {
                onEnableAI()
            } label: {
                Label("Enable AI for smarter task entry", systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.primary)
            }
            .padding(.bottom, DS.Spacing.sm)
        }
        .background(DS.Colors.cardBackground)
    }
}
```

### 3. PlannerView.swift (Integrate AI Features)

```swift
struct PlannerView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore

    @State private var showRescheduleBanner = false
    @State private var rescheduleSuggestion: RescheduleSuggestion?
    @State private var currentInsight: AIInsight?

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Header with date picker (existing)
                PlannerHeaderView()

                // NEW: AI Insight Card (dismissible)
                if let insight = currentInsight {
                    AIInsightCard(insight: insight) {
                        withAnimation { currentInsight = nil }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Timeline (existing)
                TimelineView()

                Divider()

                // NEW: AI Quick Add at bottom
                if ai.isConfigured {
                    AIQuickAddBar(destination: .schedule)
                }
            }

            // NEW: Reschedule Banner (overlay at top)
            if showRescheduleBanner, let suggestion = rescheduleSuggestion {
                RescheduleBanner(
                    suggestion: suggestion,
                    onAccept: { applyReschedule(suggestion) },
                    onDismiss: { showRescheduleBanner = false }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .onAppear {
            checkScheduleHealth()
        }
        .onChange(of: taskStore.tasksForSelectedDate) { _, _ in
            checkScheduleHealth()
        }
    }

    private func checkScheduleHealth() {
        // Check if running late and show banner
        Task {
            if let suggestion = await ai.checkForRescheduleNeeded(
                tasks: taskStore.tasksForSelectedDate
            ) {
                await MainActor.run {
                    rescheduleSuggestion = suggestion
                    withAnimation { showRescheduleBanner = true }
                }
            }
        }
    }
}
```

### 4. FABButton.swift (Add Brain Dump Option)

```swift
struct FABButton: View {
    @State private var showMenu = false
    @State private var showAddTask = false
    @State private var showBrainDump = false
    @State private var showVoiceInput = false

    var body: some View {
        Menu {
            Button {
                showAddTask = true
            } label: {
                Label("Add Task", systemImage: "plus")
            }

            Divider()

            // NEW: Brain Dump
            Button {
                showBrainDump = true
            } label: {
                Label("Brain Dump", systemImage: "brain.head.profile")
            }

            // NEW: Voice Input
            Button {
                showVoiceInput = true
            } label: {
                Label("Voice Input", systemImage: "mic.fill")
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: DS.Sizes.fab, height: DS.Sizes.fab)
                .background(DS.Colors.primary)
                .clipShape(Circle())
                .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, y: 4)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
        .sheet(isPresented: $showBrainDump) {
            BrainDumpView()
        }
        .sheet(isPresented: $showVoiceInput) {
            VoiceInputSheet()
        }
    }
}
```

### 5. TaskCardView.swift (Add AI Context Menu)

```swift
struct TaskCardView: View {
    let task: TaskItem

    @Environment(AICoordinator.self) private var ai
    @State private var showBreakdown = false
    @State private var showReschedule = false

    var body: some View {
        // Existing task card content
        TaskCardContent(task: task)
            .contextMenu {
                // Existing actions
                Button {
                    // edit
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    // delete
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                // NEW: AI Actions (only show if AI configured)
                if ai.isConfigured {
                    Divider()

                    Button {
                        showBreakdown = true
                    } label: {
                        Label("Break down with AI", systemImage: "sparkles")
                    }

                    Button {
                        showReschedule = true
                    } label: {
                        Label("Find better time", systemImage: "calendar.badge.clock")
                    }
                }
            }
            .sheet(isPresented: $showBreakdown) {
                TaskBreakdownSheet(taskTitle: task.title) { subtasks in
                    task.subtasks = subtasks
                }
            }
            .sheet(isPresented: $showReschedule) {
                ScheduleSuggestionsSheet(
                    taskTitle: task.title,
                    duration: task.duration,
                    energyLevel: task.energyLevel
                ) { newTime in
                    task.startTime = newTime
                }
            }
    }
}
```

### 6. BottomTabBar.swift (UNCHANGED)

```swift
// NO CHANGES - Keep exactly as is
struct BottomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            TabButton(tab: .todo, selectedTab: $selectedTab)
            TabButton(tab: .planner, selectedTab: $selectedTab)
        }
        // ... existing styling
    }
}

// Tab enum stays the same
enum Tab {
    case todo
    case planner
    // NO "ai" case - AI is integrated, not a tab
}
```

---

## Cost Estimates

| Feature | Tokens/Request | Requests/Day | Daily Cost (Gemini) |
|---------|---------------|--------------|---------------------|
| Task parsing | ~300 | 20 | $0.002 |
| Brain dump | ~800 | 2 | $0.001 |
| Task breakdown | ~500 | 5 | $0.001 |
| Scheduling | ~600 | 10 | $0.003 |
| **Total** | - | ~37 | **~$0.007/day** |

**Monthly estimate**: ~$0.21/user (with moderate usage)

---

## Implementation Timeline

### Week 1: Foundation (Phase 0)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | LLM Service core | `LLMProvider.swift`, `LLMService.swift`, `LLMError.swift` |
| 3 | Keychain storage | `KeychainManager.swift` |
| 4-5 | Test all 4 providers | Manual testing with each API |

**Deliverable**: Can make LLM API calls to Gemini/OpenAI/Anthropic

### Week 2: Core AI (Phase 1)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | Prompt templates | `PromptTemplates.swift` |
| 3-4 | AI Coordinator | `AICoordinator.swift` |
| 5 | Response models | `AIModels.swift` |

**Deliverable**: `AICoordinator.parseTask("gym tomorrow 7am")` works

### Week 3: UI Components (Phase 2)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | Onboarding flow | `AIOnboardingView.swift` |
| 3-4 | AI Quick Add bar | `AIQuickAddBar.swift` |
| 5 | Voice input sheet | `VoiceInputSheet.swift` |

**Deliverable**: Users can set up AI and use natural language input

### Week 4: Brain Dump & Integration (Phase 2 continued)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | Brain Dump view | `BrainDumpView.swift` |
| 3 | Integrate into TodoView | Modify `TodoView.swift` |
| 4 | Integrate into PlannerView | Modify `PlannerView.swift` |
| 5 | FAB menu updates | Modify `FABButton.swift` |

**Deliverable**: Brain Dump works, AI integrated into both tabs

### Week 5: Advanced Features (Phase 3)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | Task breakdown | `TaskBreakdownSheet.swift` |
| 3-4 | Schedule suggestions | `ScheduleSuggestionsSheet.swift` |
| 5 | Context menu integration | Modify `TaskCardView.swift`, `TodoDetailView.swift` |

**Deliverable**: Task breakdown and AI scheduling work

### Week 6: Contextual AI (Phase 3 continued)

| Day | Task | Files |
|-----|------|-------|
| 1-2 | Reschedule banner | `RescheduleBanner.swift` |
| 3-4 | Insight cards | `AIInsightCard.swift` |
| 5 | Planner integration | Modify `PlannerView.swift` |

**Deliverable**: Contextual AI banners appear when needed

### Week 7: Polish & Testing

| Day | Task |
|-----|------|
| 1-2 | Error handling & edge cases |
| 3-4 | Performance optimization (caching, debouncing) |
| 5 | Final testing on all providers |

**Deliverable**: Production-ready AI features

---

## Quick Start Checklist

To begin implementation, complete these steps in order:

- [ ] Create `Focal/Services/AI/` folder
- [ ] Create `Focal/Models/AI/` folder
- [ ] Create `Focal/Views/AI/` folder
- [ ] Implement `LLMProvider.swift`
- [ ] Implement `LLMError.swift`
- [ ] Implement `KeychainManager.swift`
- [ ] Implement `LLMService.swift`
- [ ] Test with Gemini API key
- [ ] Add `AICoordinator` to `FocalApp.swift` environment
- [ ] Continue with remaining phases...

---

*Document Version: 2.1*
*Created: January 2026*
*Updated: January 2026*
*Approach: Pure LLM-based AI, integrated into existing tabs*
