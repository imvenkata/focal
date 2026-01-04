import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var icon: String
    var colorName: String
    var startTime: Date
    var duration: TimeInterval
    var isRoutine: Bool
    var repeatDays: [Int]
    var reminderOption: String?
    var energyLevel: Int
    @Relationship(deleteRule: .cascade) var subtasks: [Subtask]
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        icon: String = "📝",
        colorName: String = "sage",
        startTime: Date = Date(),
        duration: TimeInterval = 3600,
        isRoutine: Bool = false,
        repeatDays: [Int] = [],
        reminderOption: String? = nil,
        energyLevel: Int = 2,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorName = colorName
        self.startTime = startTime
        self.duration = duration
        self.isRoutine = isRoutine
        self.repeatDays = repeatDays
        self.reminderOption = reminderOption
        self.energyLevel = energyLevel
        self.subtasks = []
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var color: TaskColor {
        TaskColor(rawValue: colorName) ?? .sage
    }

    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    var timeRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    var isActive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime && !isCompleted
    }

    var isPast: Bool {
        Date() > endTime
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

    // MARK: - Methods

    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
    }

    func addSubtask(_ title: String) {
        let subtask = Subtask(title: title)
        subtasks.append(subtask)
        updatedAt = Date()
    }

    func removeSubtask(_ subtask: Subtask) {
        subtasks.removeAll { $0.id == subtask.id }
        updatedAt = Date()
    }

    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    var subtasksProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        return Double(completedSubtasksCount) / Double(subtasks.count)
    }
}

// MARK: - Reminder Option
enum ReminderOption: String, CaseIterable, Identifiable {
    case none = "None"
    case fiveMin = "5 min"
    case fifteenMin = "15 min"
    case thirtyMin = "30 min"
    case oneHour = "1 hour"

    var id: String { rawValue }

    var timeInterval: TimeInterval? {
        switch self {
        case .none: return nil
        case .fiveMin: return 5 * 60
        case .fifteenMin: return 15 * 60
        case .thirtyMin: return 30 * 60
        case .oneHour: return 60 * 60
        }
    }
}

// MARK: - Duration Presets
enum DurationPreset: CaseIterable, Identifiable {
    case fifteenMin
    case thirtyMin
    case fortyFiveMin
    case oneHour
    case oneAndHalfHour
    case twoHours

    var id: TimeInterval { duration }

    var duration: TimeInterval {
        switch self {
        case .fifteenMin: return 15 * 60
        case .thirtyMin: return 30 * 60
        case .fortyFiveMin: return 45 * 60
        case .oneHour: return 60 * 60
        case .oneAndHalfHour: return 90 * 60
        case .twoHours: return 120 * 60
        }
    }

    var label: String {
        switch self {
        case .fifteenMin: return "15m"
        case .thirtyMin: return "30m"
        case .fortyFiveMin: return "45m"
        case .oneHour: return "1h"
        case .oneAndHalfHour: return "1.5h"
        case .twoHours: return "2h"
        }
    }
}

// MARK: - Weekday
enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
