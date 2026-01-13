import Foundation
import SwiftUI

/// Represents a task instance for display in the timeline.
/// This can be either a real TaskItem or a virtual instance generated from a recurring task.
struct VirtualTaskInstance: Identifiable {
    /// Unique identifier for this instance (generated for virtual instances)
    let id: UUID

    /// The source task this instance is based on
    let sourceTask: TaskItem

    /// The date this instance occurs on (may differ from sourceTask.startTime for recurring tasks)
    let instanceDate: Date

    /// Whether this is a virtual instance (true) or the original task (false)
    let isVirtual: Bool

    /// Completion status for this specific instance
    var isCompleted: Bool

    /// When this instance was completed (if completed)
    var completedAt: Date?

    // MARK: - Initializers

    /// Create a virtual instance for a recurring task on a specific date
    init(sourceTask: TaskItem, instanceDate: Date, isCompleted: Bool = false, completedAt: Date? = nil) {
        self.id = UUID()
        self.sourceTask = sourceTask
        self.instanceDate = instanceDate
        self.isVirtual = true
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }

    /// Create an instance from a real (non-recurring) task
    init(task: TaskItem) {
        self.id = task.id
        self.sourceTask = task
        self.instanceDate = task.startTime
        self.isVirtual = false
        self.isCompleted = task.isCompleted
        self.completedAt = task.completedAt
    }

    // MARK: - Computed Properties (delegating to sourceTask)

    var title: String { sourceTask.title }
    var icon: String { sourceTask.icon }
    var colorName: String { sourceTask.colorName }
    var color: TaskColor { sourceTask.color }
    var duration: TimeInterval { sourceTask.duration }
    var energyLevel: Int { sourceTask.energyLevel }
    var energyIcon: String { sourceTask.energyIcon }
    var energyLabel: String { sourceTask.energyLabel }
    var subtasks: [Subtask] { sourceTask.subtasks }
    var notes: String? { sourceTask.notes }
    var recurrenceOption: String? { sourceTask.recurrenceOption }
    var repeatDays: [Int] { sourceTask.repeatDays }
    var reminderOption: String? { sourceTask.reminderOption }

    /// The start time for this specific instance
    var startTime: Date {
        if isVirtual {
            // Combine instanceDate with the original task's time
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: sourceTask.startTime)
            return calendar.date(
                bySettingHour: timeComponents.hour ?? 9,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: instanceDate
            ) ?? instanceDate
        } else {
            return sourceTask.startTime
        }
    }

    /// The end time for this specific instance
    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }

    /// Formatted duration string
    var durationFormatted: String {
        sourceTask.durationFormatted
    }

    /// Formatted time range
    var timeRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// Formatted start time
    var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    /// Whether the task is currently active
    var isActive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime && !isCompleted
    }

    /// Whether the task is in the past
    var isPast: Bool {
        Date() > endTime
    }

    /// Whether this is a recurring task
    var isRecurring: Bool {
        sourceTask.recurrenceOption != nil && sourceTask.recurrenceOption != "None"
    }

    /// Formatted recurrence string
    var recurrenceFormatted: String {
        sourceTask.recurrenceFormatted
    }

    /// Subtask completion count
    var completedSubtasksCount: Int {
        sourceTask.completedSubtasksCount
    }

    /// Subtask progress (0.0 to 1.0)
    var subtasksProgress: Double {
        sourceTask.subtasksProgress
    }
}

// MARK: - Equatable

extension VirtualTaskInstance: Equatable {
    static func == (lhs: VirtualTaskInstance, rhs: VirtualTaskInstance) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension VirtualTaskInstance: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
