import XCTest
@testable import Focal

/// Unit tests for AI services
final class AIServiceTests: XCTestCase {

    // MARK: - LLMService Tests

    func testExtractJSON_fromPlainJSON() {
        // Given
        let service = LLMService()
        let input = """
        {"title": "Test Task", "date": "2025-01-20"}
        """

        // When
        let result = service.extractJSON(from: input)

        // Then
        XCTAssertEqual(result, """
        {"title": "Test Task", "date": "2025-01-20"}
        """)
    }

    func testExtractJSON_fromMarkdownCodeBlock() {
        // Given
        let service = LLMService()
        let input = """
        ```json
        {"title": "Test Task"}
        ```
        """

        // When
        let result = service.extractJSON(from: input)

        // Then
        XCTAssertEqual(result, """
        {"title": "Test Task"}
        """)
    }

    func testExtractJSON_fromPlainCodeBlock() {
        // Given
        let service = LLMService()
        let input = """
        ```
        {"title": "Test Task"}
        ```
        """

        // When
        let result = service.extractJSON(from: input)

        // Then
        XCTAssertEqual(result, """
        {"title": "Test Task"}
        """)
    }

    func testExtractJSON_withWhitespace() {
        // Given
        let service = LLMService()
        let input = """

           {"title": "Test Task"}

        """

        // When
        let result = service.extractJSON(from: input)

        // Then
        XCTAssertEqual(result, """
        {"title": "Test Task"}
        """)
    }

    func testLLMService_notConfigured() async {
        // Given
        let service = LLMService()

        // When/Then
        do {
            _ = try await service.complete(prompt: "Test")
            XCTFail("Should have thrown notConfigured error")
        } catch let error as LLMError {
            XCTAssertEqual(error.errorDescription, "AI is not configured. Please add your API key in Settings.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testLLMService_emptyPromptValidation() async {
        // Given
        let service = LLMService()
        // Configure with dummy key just to pass configuration check
        service.configure(provider: .gemini, apiKey: "test-key")

        // When/Then - empty prompt should fail validation before network check
        do {
            _ = try await service.complete(prompt: "   ")
            XCTFail("Should have thrown parsing error for empty prompt")
        } catch let error as LLMError {
            // Should fail on empty prompt validation
            XCTAssertTrue(error.errorDescription?.contains("empty") ?? false)
        } catch {
            // Network error is also acceptable since we're not connected
        }
    }

    // MARK: - AICache Tests

    func testAICache_setAndGet() {
        // Given
        let cache = AICache.shared
        cache.clear()
        let prompt = "Test prompt"
        let response = "Test response"

        // When
        cache.set(response: response, prompt: prompt)
        let cached = cache.get(prompt: prompt)

        // Then
        XCTAssertEqual(cached, response)
    }

    func testAICache_differentPromptsAreSeparate() {
        // Given
        let cache = AICache.shared
        cache.clear()

        // When
        cache.set(response: "Response 1", prompt: "Prompt 1")
        cache.set(response: "Response 2", prompt: "Prompt 2")

        // Then
        XCTAssertEqual(cache.get(prompt: "Prompt 1"), "Response 1")
        XCTAssertEqual(cache.get(prompt: "Prompt 2"), "Response 2")
    }

    func testAICache_systemPromptAffectsKey() {
        // Given
        let cache = AICache.shared
        cache.clear()
        let prompt = "Same prompt"

        // When
        cache.set(response: "Response without system", prompt: prompt, systemPrompt: nil)
        cache.set(response: "Response with system", prompt: prompt, systemPrompt: "System")

        // Then
        XCTAssertEqual(cache.get(prompt: prompt, systemPrompt: nil), "Response without system")
        XCTAssertEqual(cache.get(prompt: prompt, systemPrompt: "System"), "Response with system")
    }

    func testAICache_clear() {
        // Given
        let cache = AICache.shared
        cache.set(response: "Test", prompt: "Test")

        // When
        cache.clear()

        // Then
        XCTAssertNil(cache.get(prompt: "Test"))
    }

    // MARK: - ParsedTask Tests

    func testParsedTask_toTaskItem() {
        // Given
        let parsed = ParsedTask(
            title: "Test Task",
            date: "2025-01-20",
            time: "14:30",
            durationMinutes: 60,
            energyLevel: 3,
            icon: "📝",
            color: "sky",
            isRecurring: false,
            recurrence: nil,
            priority: "medium",
            category: "todo",
            reminder: nil,
            subtasks: ["Subtask 1", "Subtask 2"],
            notes: "Test notes",
            confidence: 0.95
        )

        // When
        let taskItem = parsed.toTaskItem()

        // Then
        XCTAssertEqual(taskItem.title, "Test Task")
        XCTAssertEqual(taskItem.icon, "📝")
        XCTAssertEqual(taskItem.colorName, "sky")
        XCTAssertEqual(taskItem.duration, 3600) // 60 minutes in seconds
        XCTAssertEqual(taskItem.energyLevel, 3)
        XCTAssertEqual(taskItem.subtasks.count, 2)
    }

    func testParsedTask_toTodoItem() {
        // Given
        let parsed = ParsedTask(
            title: "Todo Test",
            date: "2025-01-20",
            time: nil,
            durationMinutes: nil,
            energyLevel: nil,
            icon: "✅",
            color: "coral",
            isRecurring: nil,
            recurrence: nil,
            priority: "high",
            category: "todo",
            reminder: nil,
            subtasks: nil,
            notes: "Important notes",
            confidence: 0.9
        )

        // When
        let todoItem = parsed.toTodoItem()

        // Then
        XCTAssertEqual(todoItem.title, "Todo Test")
        XCTAssertEqual(todoItem.icon, "✅")
        XCTAssertEqual(todoItem.colorName, "coral")
        XCTAssertEqual(todoItem.priorityEnum, .high)
        XCTAssertEqual(todoItem.notes, "Important notes")
    }

    func testParsedTask_priorityMapping() {
        // Given
        let highParsed = ParsedTask(
            title: "High", date: nil, time: nil, durationMinutes: nil,
            energyLevel: nil, icon: nil, color: nil, isRecurring: nil,
            recurrence: nil, priority: "high", category: nil, reminder: nil,
            subtasks: nil, notes: nil, confidence: 1.0
        )
        let lowParsed = ParsedTask(
            title: "Low", date: nil, time: nil, durationMinutes: nil,
            energyLevel: nil, icon: nil, color: nil, isRecurring: nil,
            recurrence: nil, priority: "low", category: nil, reminder: nil,
            subtasks: nil, notes: nil, confidence: 1.0
        )

        // When
        let highTodo = highParsed.toTodoItem()
        let lowTodo = lowParsed.toTodoItem()

        // Then
        XCTAssertEqual(highTodo.priorityEnum, .high)
        XCTAssertEqual(lowTodo.priorityEnum, .low)
    }

    // MARK: - LLMError Tests

    func testLLMError_isRetryable() {
        // Retryable errors
        XCTAssertTrue(LLMError.rateLimited(retryAfter: nil).isRetryable)
        XCTAssertTrue(LLMError.serverError(statusCode: 500, message: "").isRetryable)
        XCTAssertTrue(LLMError.networkError(URLError(.timedOut)).isRetryable)
        XCTAssertTrue(LLMError.providerUnavailable.isRetryable)

        // Non-retryable errors
        XCTAssertFalse(LLMError.notConfigured.isRetryable)
        XCTAssertFalse(LLMError.invalidAPIKey.isRetryable)
        XCTAssertFalse(LLMError.parsingFailed("").isRetryable)
        XCTAssertFalse(LLMError.contextTooLong.isRetryable)
    }

    func testLLMError_descriptions() {
        XCTAssertNotNil(LLMError.notConfigured.errorDescription)
        XCTAssertNotNil(LLMError.invalidAPIKey.errorDescription)
        XCTAssertNotNil(LLMError.rateLimited(retryAfter: 30).errorDescription)
        XCTAssertTrue(LLMError.rateLimited(retryAfter: 30).errorDescription!.contains("30"))
    }

    // MARK: - AICoordinator Tests

    func testAICoordinator_cancelPendingOperations() {
        // Given
        let coordinator = AICoordinator()

        // When/Then - should not crash
        coordinator.cancelPendingOperations()
    }

    func testAICoordinator_isConfigured_defaultsFalse() {
        // Given
        let coordinator = AICoordinator()

        // Then
        XCTAssertFalse(coordinator.isConfigured)
    }
}
