import Foundation
import SwiftData
import SwiftUI

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var icon: String
    var colorName: String
    var priority: String
    var category: String
    @Relationship(deleteRule: .cascade) var subtasks: [TodoSubtask]
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int

    // MARK: - Premium Fields
    var dueDate: Date?
    var dueTime: Date?
    var hasDueTime: Bool
    var reminderOption: String?
    var recurrenceOption: String?
    var repeatDays: [Int]
    var energyLevel: Int
    var estimatedDuration: TimeInterval?
    var isArchived: Bool
    var tags: [String]

    init(
        title: String,
        icon: String = "📝",
        colorName: String = "sky",
        priority: TodoPriority = .medium,
        category: TodoCategory = .todo,
        notes: String? = nil,
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        reminderOption: String? = nil,
        recurrenceOption: String? = nil,
        repeatDays: [Int] = [],
        energyLevel: Int = 2,
        estimatedDuration: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorName = colorName
        self.priority = priority.rawValue
        self.category = category.rawValue
        self.subtasks = []
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.orderIndex = 0

        // Premium fields
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.hasDueTime = dueTime != nil
        self.reminderOption = reminderOption
        self.recurrenceOption = recurrenceOption
        self.repeatDays = repeatDays
        self.energyLevel = energyLevel
        self.estimatedDuration = estimatedDuration
        self.isArchived = false
        self.tags = []
    }

    // MARK: - Computed Properties

    var priorityEnum: TodoPriority {
        TodoPriority(rawValue: priority) ?? .medium
    }

    var categoryEnum: TodoCategory {
        TodoCategory(rawValue: category) ?? .todo
    }

    var color: TaskColor {
        TaskColor(rawValue: colorName) ?? .sky
    }

    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    var totalSubtasks: Int {
        subtasks.count
    }

    var subtasksProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        return Double(completedSubtasksCount) / Double(totalSubtasks)
    }

    var hasSubtasks: Bool {
        !subtasks.isEmpty
    }

    // MARK: - Methods

    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
    }

    func addSubtask(_ title: String) {
        let orderIndex = subtasks.count
        let subtask = TodoSubtask(title: title, orderIndex: orderIndex)
        subtasks.append(subtask)
        updatedAt = Date()
    }

    func removeSubtask(_ subtask: TodoSubtask) {
        subtasks.removeAll { $0.id == subtask.id }
        // Reindex remaining subtasks
        for (index, subtask) in subtasks.enumerated() {
            subtask.orderIndex = index
        }
        updatedAt = Date()
    }

    func setPriority(_ priority: TodoPriority) {
        self.priority = priority.rawValue
        updatedAt = Date()
    }

    func setCategory(_ category: TodoCategory) {
        self.category = category.rawValue
        updatedAt = Date()
    }

    func setDueDate(_ date: Date?) {
        self.dueDate = date
        updatedAt = Date()
    }

    func setDueTime(_ time: Date?) {
        self.dueTime = time
        self.hasDueTime = time != nil
        updatedAt = Date()
    }

    func setReminder(_ option: TodoReminderOption) {
        self.reminderOption = option == .none ? nil : option.rawValue
        updatedAt = Date()
    }

    func setRecurrence(_ option: TodoRecurrenceOption, days: [Int] = []) {
        self.recurrenceOption = option == .none ? nil : option.rawValue
        self.repeatDays = days
        updatedAt = Date()
    }

    func setEnergyLevel(_ level: Int) {
        self.energyLevel = max(0, min(4, level))
        updatedAt = Date()
    }

    func archive() {
        isArchived = true
        updatedAt = Date()
    }

    func unarchive() {
        isArchived = false
        updatedAt = Date()
    }

    // MARK: - Premium Computed Properties

    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        if hasDueTime, let dueTime = dueTime {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)
            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute
            if let fullDate = calendar.date(from: combined) {
                return Date() > fullDate
            }
        }
        return Calendar.current.startOfDay(for: Date()) > Calendar.current.startOfDay(for: dueDate)
    }

    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }

    var isDueThisWeek: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var dueDateFormatted: String? {
        guard let dueDate = dueDate else { return nil }

        if isDueToday {
            return "Today"
        } else if isDueTomorrow {
            return "Tomorrow"
        } else if isOverdue {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: dueDate, relativeTo: Date())
        } else {
            let formatter = DateFormatter()
            if Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .year) {
                formatter.dateFormat = "E, MMM d"
            } else {
                formatter.dateFormat = "E, MMM d, yyyy"
            }
            return formatter.string(from: dueDate)
        }
    }

    var dueTimeFormatted: String? {
        guard hasDueTime, let dueTime = dueTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: dueTime)
    }

    var reminderFormatted: String {
        guard let option = reminderOption else { return "None" }
        return TodoReminderOption(rawValue: option)?.displayName ?? option
    }

    var recurrenceFormatted: String {
        guard let option = recurrenceOption, option != "None" else { return "" }

        if option == "Custom", !repeatDays.isEmpty {
            if repeatDays.count == 7 { return "Every day" }
            if repeatDays.sorted() == [1, 2, 3, 4, 5] { return "Weekdays" }
            if repeatDays.sorted() == [0, 6] { return "Weekends" }
            let days = repeatDays.sorted().compactMap { Weekday(rawValue: $0)?.shortName }
            return days.joined(separator: " ")
        }

        return option
    }

    var energyIcon: String {
        switch energyLevel {
        case 0: return "🌿"
        case 1: return "◎"
        case 2: return "🔥"
        case 3: return "🔥🔥"
        case 4: return "🔥🔥🔥"
        default: return "🔥"
        }
    }

    var energyLabel: String {
        switch energyLevel {
        case 0: return "Restful"
        case 1: return "Light"
        case 2: return "Moderate"
        case 3: return "High"
        case 4: return "Intense"
        default: return "Moderate"
        }
    }

    var estimatedDurationFormatted: String? {
        guard let duration = estimatedDuration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        }
        return nil
    }

    var statusBadge: (text: String, color: Color)? {
        if isCompleted {
            return ("Done", DS.Colors.success)
        } else if isOverdue {
            return ("Overdue", DS.Colors.danger)
        } else if isDueToday {
            return ("Today", DS.Colors.warning)
        }
        return nil
    }
}

// MARK: - Todo Reminder Options

enum TodoReminderOption: String, CaseIterable, Identifiable {
    case none = "None"
    case atTime = "At time"
    case fiveMin = "5 min before"
    case fifteenMin = "15 min before"
    case thirtyMin = "30 min before"
    case oneHour = "1 hour before"
    case oneDay = "1 day before"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var timeInterval: TimeInterval? {
        switch self {
        case .none: return nil
        case .atTime: return 0
        case .fiveMin: return 5 * 60
        case .fifteenMin: return 15 * 60
        case .thirtyMin: return 30 * 60
        case .oneHour: return 60 * 60
        case .oneDay: return 24 * 60 * 60
        }
    }

    var icon: String {
        switch self {
        case .none: return "bell.slash"
        case .atTime: return "bell.badge"
        default: return "bell"
        }
    }
}

// MARK: - Todo Recurrence Options

enum TodoRecurrenceOption: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .none: return "arrow.clockwise.circle"
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar"
        case .monthly: return "calendar.circle"
        case .yearly: return "gift"
        case .custom: return "slider.horizontal.3"
        }
    }
}

// MARK: - Todo Categories

enum TodoCategory: String, CaseIterable, Identifiable {
    case todo = "todo"
    case routine = "routine"
    case event = "event"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .todo: return "To-do"
        case .routine: return "Routine"
        case .event: return "Event"
        }
    }

    var icon: String {
        switch self {
        case .todo: return "📋"
        case .routine: return "🔁"
        case .event: return "📅"
        }
    }

    var tint: Color {
        switch self {
        case .todo: return DS.Colors.slate
        case .routine: return DS.Colors.sage
        case .event: return DS.Colors.sky
        }
    }
}

// MARK: - Todo Duration Presets

enum TodoDurationPreset: CaseIterable, Identifiable {
    case fifteenMin
    case thirtyMin
    case fortyFiveMin
    case oneHour
    case twoHours
    case halfDay
    case fullDay

    var id: TimeInterval { duration }

    var duration: TimeInterval {
        switch self {
        case .fifteenMin: return 15 * 60
        case .thirtyMin: return 30 * 60
        case .fortyFiveMin: return 45 * 60
        case .oneHour: return 60 * 60
        case .twoHours: return 120 * 60
        case .halfDay: return 4 * 60 * 60
        case .fullDay: return 8 * 60 * 60
        }
    }

    var label: String {
        switch self {
        case .fifteenMin: return "15m"
        case .thirtyMin: return "30m"
        case .fortyFiveMin: return "45m"
        case .oneHour: return "1h"
        case .twoHours: return "2h"
        case .halfDay: return "4h"
        case .fullDay: return "8h"
        }
    }
}
