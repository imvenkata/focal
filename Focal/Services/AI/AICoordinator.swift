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
        lastError = nil
        do {
            let prompt = PromptTemplates.parseTask(input: input)
            return try await llm.completeJSON(
                prompt: prompt,
                systemPrompt: PromptTemplates.taskParsingSystem,
                responseType: ParsedTask.self
            )
        } catch let error as LLMError {
            lastError = error
            throw error
        }
    }

    // MARK: - Brain Dump

    /// Organize brain dump into structured tasks
    func organizeBrainDump(_ input: String) async throws -> OrganizedBrainDump {
        lastError = nil
        do {
            let prompt = PromptTemplates.organizeBrainDump(input: input)
            return try await llm.completeJSON(
                prompt: prompt,
                systemPrompt: PromptTemplates.brainDumpSystem,
                responseType: OrganizedBrainDump.self
            )
        } catch let error as LLMError {
            lastError = error
            throw error
        }
    }

    // MARK: - Task Breakdown

    /// Break complex task into subtasks
    func breakdownTask(_ task: String, context: String? = nil) async throws -> TaskBreakdown {
        lastError = nil
        do {
            let prompt = PromptTemplates.breakdownTask(task: task, context: context)
            return try await llm.completeJSON(
                prompt: prompt,
                systemPrompt: PromptTemplates.taskParsingSystem,
                responseType: TaskBreakdown.self
            )
        } catch let error as LLMError {
            lastError = error
            throw error
        }
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
        lastError = nil

        let existingFormatted = existingTasks.map { task in
            "\(task.startTime.formatted(date: .omitted, time: .shortened)) - \(task.endTime.formatted(date: .omitted, time: .shortened)): \(task.title)"
        }

        // TODO: Get real user patterns from PatternStore
        let patterns = "Typically most productive 9-11am and 2-4pm"

        do {
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
        } catch let error as LLMError {
            lastError = error
            throw error
        }
    }

    // MARK: - Rescheduling

    /// Get rescheduling suggestions when plans change
    func suggestReschedule(
        situation: String,
        affectedTasks: [TaskItem],
        remainingHours: Double
    ) async throws -> RescheduleSuggestion {
        lastError = nil

        let tasksFormatted = affectedTasks.map { task in
            "\(task.startTime.formatted(date: .omitted, time: .shortened)): \(task.title) (\(task.durationFormatted))"
        }

        do {
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
        } catch let error as LLMError {
            lastError = error
            throw error
        }
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
        lastError = nil

        let completionData = """
        Completion rate: \(Int(completionRate * 100))%
        Tasks completed this week: \(tasksCompleted)
        Tasks scheduled: \(tasksScheduled)
        Average task duration: \(Int(averageDuration / 60)) minutes
        """

        let patterns = "Top categories: \(topCategories.joined(separator: ", "))"
        let recentActivity = "Active user with regular task scheduling"

        do {
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
        } catch let error as LLMError {
            lastError = error
            throw error
        }
    }
}
