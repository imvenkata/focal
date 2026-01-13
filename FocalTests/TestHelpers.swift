import XCTest
import SwiftData
@testable import Focal

/// Test helpers and fixtures for Focal unit tests
enum TestHelpers {

    // MARK: - SwiftData Setup

    /// Create an in-memory model container for testing
    static func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            TaskItem.self,
            Subtask.self,
            TodoItem.self,
            TodoSubtask.self,
            TaskCompletionRecord.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    // MARK: - Task Fixtures

    /// Create a sample task for testing
    static func createSampleTask(
        title: String = "Test Task",
        icon: String = "@",
        colorName: String = "coral",
        startTime: Date = Date(),
        duration: TimeInterval = 3600,
        recurrenceOption: String? = nil,
        repeatDays: [Int] = [],
        reminderOption: String? = nil,
        energyLevel: Int = 2,
        isCompleted: Bool = false
    ) -> TaskItem {
        let task = TaskItem(
            title: title,
            icon: icon,
            colorName: colorName,
            startTime: startTime,
            duration: duration,
            recurrenceOption: recurrenceOption,
            repeatDays: repeatDays,
            reminderOption: reminderOption,
            energyLevel: energyLevel
        )
        if isCompleted {
            task.toggleCompletion()
        }
        return task
    }

    /// Create a daily recurring task
    static func createDailyTask(
        title: String = "Daily Task",
        startTime: Date = Date()
    ) -> TaskItem {
        return createSampleTask(
            title: title,
            startTime: startTime,
            recurrenceOption: "Daily"
        )
    }

    /// Create a weekly recurring task
    static func createWeeklyTask(
        title: String = "Weekly Task",
        startTime: Date = Date()
    ) -> TaskItem {
        return createSampleTask(
            title: title,
            startTime: startTime,
            recurrenceOption: "Weekly"
        )
    }

    /// Create a custom recurrence task
    static func createCustomRecurrenceTask(
        title: String = "Custom Task",
        startTime: Date = Date(),
        repeatDays: [Int] = [1, 3, 5] // Mon, Wed, Fri
    ) -> TaskItem {
        return createSampleTask(
            title: title,
            startTime: startTime,
            recurrenceOption: "Custom",
            repeatDays: repeatDays
        )
    }

    // MARK: - Todo Fixtures

    /// Create a sample todo for testing
    static func createSampleTodo(
        title: String = "Test Todo",
        icon: String = "@",
        colorName: String = "sage",
        priority: TodoPriority = .medium,
        dueDate: Date? = nil,
        isCompleted: Bool = false
    ) -> TodoItem {
        let todo = TodoItem(
            title: title,
            icon: icon,
            colorName: colorName,
            priority: priority
        )
        if let dueDate {
            todo.setDueDate(dueDate)
        }
        if isCompleted {
            todo.toggleCompletion()
        }
        return todo
    }

    /// Create a high priority todo due today
    static func createUrgentTodo(title: String = "Urgent Task") -> TodoItem {
        return createSampleTodo(
            title: title,
            priority: .high,
            dueDate: Date()
        )
    }

    /// Create an overdue todo
    static func createOverdueTodo(title: String = "Overdue Task") -> TodoItem {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return createSampleTodo(
            title: title,
            priority: .medium,
            dueDate: yesterday
        )
    }

    // MARK: - Date Helpers

    /// Get a date at a specific hour today
    static func todayAt(hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    /// Get tomorrow's date
    static func tomorrow() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    /// Get yesterday's date
    static func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }

    /// Get a date N days from now
    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}
