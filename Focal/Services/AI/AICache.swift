import Foundation

/// Cache for AI responses to reduce API calls and improve responsiveness
final class AICache {

    // MARK: - Types

    private struct CacheEntry {
        let response: String
        let timestamp: Date
    }

    // MARK: - Configuration

    private static let defaultTTL: TimeInterval = 3600 // 1 hour
    private static let maxEntries = 100

    // MARK: - Singleton

    static let shared = AICache()

    // MARK: - Storage

    private let cache = NSCache<NSString, CacheEntryWrapper>()
    private var keys = Set<String>()
    private let lock = NSLock()

    private init() {
        cache.countLimit = Self.maxEntries
    }

    // MARK: - Public API

    /// Get cached response for a prompt
    func get(prompt: String, systemPrompt: String? = nil) -> String? {
        let key = cacheKey(prompt: prompt, systemPrompt: systemPrompt)

        guard let wrapper = cache.object(forKey: key as NSString) else {
            return nil
        }

        // Check if expired
        if Date().timeIntervalSince(wrapper.timestamp) > Self.defaultTTL {
            cache.removeObject(forKey: key as NSString)
            lock.lock()
            keys.remove(key)
            lock.unlock()
            return nil
        }

        return wrapper.response
    }

    /// Cache a response for a prompt
    func set(response: String, prompt: String, systemPrompt: String? = nil) {
        let key = cacheKey(prompt: prompt, systemPrompt: systemPrompt)
        let wrapper = CacheEntryWrapper(response: response, timestamp: Date())

        cache.setObject(wrapper, forKey: key as NSString)

        lock.lock()
        keys.insert(key)
        lock.unlock()
    }

    /// Clear all cached responses
    func clear() {
        cache.removeAllObjects()
        lock.lock()
        keys.removeAll()
        lock.unlock()
    }

    /// Clear expired entries
    func clearExpired() {
        lock.lock()
        let currentKeys = keys
        lock.unlock()

        let now = Date()
        for key in currentKeys {
            if let wrapper = cache.object(forKey: key as NSString),
               now.timeIntervalSince(wrapper.timestamp) > Self.defaultTTL {
                cache.removeObject(forKey: key as NSString)
                lock.lock()
                keys.remove(key)
                lock.unlock()
            }
        }
    }

    // MARK: - Helpers

    private func cacheKey(prompt: String, systemPrompt: String?) -> String {
        let combined = "\(systemPrompt ?? "")|\(prompt)"
        // Use hash for shorter key
        return String(combined.hashValue)
    }
}

// MARK: - Wrapper for NSCache

/// Wrapper class for storing in NSCache (requires reference type)
private final class CacheEntryWrapper {
    let response: String
    let timestamp: Date

    init(response: String, timestamp: Date) {
        self.response = response
        self.timestamp = timestamp
    }
}
