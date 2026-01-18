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

    /// Convert to TaskItem for Planner
    func toTaskItem() -> TaskItem {
        let task = TaskItem(
            title: title,
            startTime: resolvedStartTime ?? Date(),
            duration: TimeInterval((durationMinutes ?? 30) * 60)
        )

        task.icon = icon ?? "📌"
        task.colorName = color ?? "sky"
        task.energyLevel = energyLevel ?? 2

        // Set recurrence if specified
        if isRecurring == true, let recurrence = recurrence {
            let (option, days) = resolveRecurrence(recurrence)
            task.recurrenceOption = option
            task.repeatDays = days
        }

        return task
    }

    /// Convert recurrence string to RecurrenceOption and repeatDays
    private func resolveRecurrence(_ recurrence: String) -> (String, [Int]) {
        switch recurrence.lowercased() {
        case "daily", "every day", "everyday":
            return ("Custom", [0, 1, 2, 3, 4, 5, 6]) // All days
        case "weekly":
            return ("Weekly", [])
        case "weekdays", "every weekday":
            return ("Custom", [1, 2, 3, 4, 5]) // Mon-Fri
        case "weekends", "every weekend":
            return ("Custom", [0, 6]) // Sun, Sat
        case "biweekly":
            return ("Biweekly", [])
        case "monthly":
            return ("Monthly", [])
        default:
            return ("Daily", [])
        }
    }

    /// Convert to TodoItem for Todo list
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
        guard time != nil else { return date }
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
