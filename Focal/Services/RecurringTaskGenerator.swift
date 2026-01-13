import Foundation

/// Generates virtual instances for recurring tasks
struct RecurringTaskGenerator {

    // MARK: - Main Generation Methods

    /// Check if a recurring task occurs on a specific date
    static func occurs(task: TaskItem, on date: Date) -> Bool {
        guard let recurrenceOption = task.recurrenceOption,
              recurrenceOption != "None",
              let option = RecurrenceOption(rawValue: recurrenceOption) else {
            return false
        }

        let calendar = Calendar.current
        let taskDate = task.startTime

        switch option {
        case .none:
            return false

        case .daily:
            // Task occurs every day after the original date
            return calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending

        case .weekly:
            // Task occurs on the same weekday every week
            guard calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending else {
                return false
            }
            return calendar.component(.weekday, from: date) == calendar.component(.weekday, from: taskDate)

        case .biweekly:
            // Task occurs on the same weekday every two weeks
            guard calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending else {
                return false
            }
            guard calendar.component(.weekday, from: date) == calendar.component(.weekday, from: taskDate) else {
                return false
            }
            // Check if it's an even number of weeks since the start
            let weeks = calendar.dateComponents([.weekOfYear], from: taskDate, to: date).weekOfYear ?? 0
            return weeks % 2 == 0

        case .monthly:
            // Task occurs on the same day of the month
            guard calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending else {
                return false
            }
            return calendar.component(.day, from: date) == calendar.component(.day, from: taskDate)

        case .yearly:
            // Task occurs on the same month and day
            guard calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending else {
                return false
            }
            let dateComponents = calendar.dateComponents([.month, .day], from: date)
            let taskComponents = calendar.dateComponents([.month, .day], from: taskDate)
            return dateComponents.month == taskComponents.month && dateComponents.day == taskComponents.day

        case .custom:
            // Task occurs on selected weekdays
            guard calendar.compare(date, to: taskDate, toGranularity: .day) != .orderedAscending else {
                return false
            }
            let weekday = calendar.component(.weekday, from: date)
            // Convert Calendar weekday (1=Sunday) to our format (0=Sunday)
            let dayIndex = weekday - 1
            return task.repeatDays.contains(dayIndex)
        }
    }

    /// Generate all occurrences of a recurring task within a date range
    static func generateOccurrences(
        for task: TaskItem,
        in dateRange: ClosedRange<Date>,
        completionRecords: [TaskCompletionRecord] = []
    ) -> [VirtualTaskInstance] {
        guard let recurrenceOption = task.recurrenceOption,
              recurrenceOption != "None" else {
            return []
        }

        let calendar = Calendar.current
        var instances: [VirtualTaskInstance] = []

        // Get the start date (either the task's start date or the range start, whichever is later)
        let taskStartDay = calendar.startOfDay(for: task.startTime)
        let rangeStartDay = calendar.startOfDay(for: dateRange.lowerBound)
        let effectiveStart = max(taskStartDay, rangeStartDay)

        // Iterate through each day in the range
        var currentDate = effectiveStart
        let rangeEnd = calendar.startOfDay(for: dateRange.upperBound)

        while currentDate <= rangeEnd {
            if occurs(task: task, on: currentDate) {
                // Check if there's a completion record for this date
                let isCompleted = completionRecords.contains { record in
                    record.taskId == task.id &&
                    calendar.isDate(record.completedDate, inSameDayAs: currentDate)
                }
                let completedAt = completionRecords.first { record in
                    record.taskId == task.id &&
                    calendar.isDate(record.completedDate, inSameDayAs: currentDate)
                }?.completedAt

                let instance = VirtualTaskInstance(
                    sourceTask: task,
                    instanceDate: currentDate,
                    isCompleted: isCompleted,
                    completedAt: completedAt
                )
                instances.append(instance)
            }

            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return instances
    }

    /// Generate occurrences for a specific date only
    static func generateOccurrencesForDate(
        task: TaskItem,
        date: Date,
        completionRecords: [TaskCompletionRecord] = []
    ) -> VirtualTaskInstance? {
        guard occurs(task: task, on: date) else {
            return nil
        }

        let calendar = Calendar.current

        // Check completion status
        let isCompleted = completionRecords.contains { record in
            record.taskId == task.id &&
            calendar.isDate(record.completedDate, inSameDayAs: date)
        }
        let completedAt = completionRecords.first { record in
            record.taskId == task.id &&
            calendar.isDate(record.completedDate, inSameDayAs: date)
        }?.completedAt

        return VirtualTaskInstance(
            sourceTask: task,
            instanceDate: date,
            isCompleted: isCompleted,
            completedAt: completedAt
        )
    }

    // MARK: - Helper Methods

    /// Get the next occurrence date for a recurring task after a given date
    static func nextOccurrence(for task: TaskItem, after date: Date) -> Date? {
        guard let recurrenceOption = task.recurrenceOption,
              recurrenceOption != "None",
              let _ = RecurrenceOption(rawValue: recurrenceOption) else {
            return nil
        }

        let calendar = Calendar.current
        var nextDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date

        // Search up to 365 days ahead
        for _ in 0..<365 {
            if occurs(task: task, on: nextDate) {
                return nextDate
            }
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }

        return nil
    }

    /// Check if a task is recurring
    static func isRecurring(_ task: TaskItem) -> Bool {
        guard let recurrenceOption = task.recurrenceOption else {
            return false
        }
        return recurrenceOption != "None"
    }
}
