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
