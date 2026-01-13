import Foundation
import UserNotifications

@Observable
final class TaskNotificationService {
    static let shared = TaskNotificationService()

    private(set) var isAuthorized = false
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                isAuthorized = granted
                authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notifications

    func scheduleReminder(for task: TaskItem) async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }

        // Remove existing notifications for this task
        await removeReminder(for: task)

        // Check if reminder is set
        guard let reminderOption = task.reminderOption,
              reminderOption != "None",
              let option = ReminderOption(rawValue: reminderOption),
              let timeInterval = option.timeInterval else {
            return
        }

        // Calculate notification date (startTime minus reminder offset)
        let notificationDate = task.startTime.addingTimeInterval(-timeInterval)

        // Don't schedule if the date is in the past
        guard notificationDate > Date() else { return }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = createNotificationBody(for: task, option: option)
        content.sound = .default
        content.badge = 1

        // Add category for actions
        content.categoryIdentifier = "TASK_REMINDER"

        // Add user info
        content.userInfo = [
            "taskId": task.id.uuidString,
            "type": "reminder"
        ]

        // Create trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "task-reminder-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled reminder for '\(task.title)' at \(notificationDate)")
        } catch {
            print("Error scheduling task notification: \(error)")
        }
    }

    func removeReminder(for task: TaskItem) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task-reminder-\(task.id.uuidString)"]
        )
        // Also remove recurring reminders
        removeRecurringReminders(for: task)
    }

    func removeReminder(forTaskId taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task-reminder-\(taskId.uuidString)"]
        )
    }

    private func removeRecurringReminders(for task: TaskItem) {
        var identifiers: [String] = []

        // Remove all possible recurring notification identifiers
        identifiers.append("task-daily-\(task.id.uuidString)")
        identifiers.append("task-weekly-\(task.id.uuidString)")
        identifiers.append("task-monthly-\(task.id.uuidString)")
        identifiers.append("task-yearly-\(task.id.uuidString)")

        // Remove biweekly (8 possible)
        for i in 0..<8 {
            identifiers.append("task-biweekly-\(task.id.uuidString)-\(i)")
        }

        // Remove custom (7 possible days)
        for day in 0..<7 {
            identifiers.append("task-custom-\(task.id.uuidString)-\(day)")
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Recurring Notifications

    func scheduleRecurringReminders(for task: TaskItem) async {
        guard isAuthorized else { return }

        // Remove existing
        await removeReminder(for: task)

        guard let recurrenceOption = task.recurrenceOption,
              recurrenceOption != "None",
              let option = RecurrenceOption(rawValue: recurrenceOption) else {
            return
        }

        // Handle different recurrence types
        switch option {
        case .none:
            break
        case .daily:
            await scheduleDailyReminder(for: task)
        case .weekly:
            await scheduleWeeklyReminder(for: task)
        case .biweekly:
            await scheduleBiweeklyReminder(for: task)
        case .monthly:
            await scheduleMonthlyReminder(for: task)
        case .yearly:
            await scheduleYearlyReminder(for: task)
        case .custom:
            await scheduleCustomReminder(for: task)
        }
    }

    private func scheduleDailyReminder(for task: TaskItem) async {
        let content = createRecurringContent(for: task)
        let components = Calendar.current.dateComponents([.hour, .minute], from: task.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "task-daily-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleWeeklyReminder(for task: TaskItem) async {
        let content = createRecurringContent(for: task)
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: task.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "task-weekly-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleBiweeklyReminder(for task: TaskItem) async {
        // For biweekly, we schedule individual notifications for the next 8 occurrences
        for i in 0..<8 {
            guard let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: i * 2, to: task.startTime) else {
                continue
            }

            // Skip if in the past
            guard nextDate > Date() else { continue }

            let content = createRecurringContent(for: task)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            await scheduleNotification(
                identifier: "task-biweekly-\(task.id.uuidString)-\(i)",
                content: content,
                trigger: trigger
            )
        }
    }

    private func scheduleMonthlyReminder(for task: TaskItem) async {
        let content = createRecurringContent(for: task)
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: task.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "task-monthly-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleYearlyReminder(for task: TaskItem) async {
        let content = createRecurringContent(for: task)
        let components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: task.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "task-yearly-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleCustomReminder(for task: TaskItem) async {
        guard !task.repeatDays.isEmpty else { return }

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: task.startTime)

        for day in task.repeatDays {
            let content = createRecurringContent(for: task)
            var components = DateComponents()
            components.weekday = day + 1 // Calendar weekdays are 1-7, our days are 0-6
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            await scheduleNotification(
                identifier: "task-custom-\(task.id.uuidString)-\(day)",
                content: content,
                trigger: trigger
            )
        }
    }

    // MARK: - Helpers

    private func createNotificationBody(for task: TaskItem, option: ReminderOption) -> String {
        switch option {
        case .none:
            return ""
        case .fiveMin:
            return "Starting in 5 minutes"
        case .fifteenMin:
            return "Starting in 15 minutes"
        case .thirtyMin:
            return "Starting in 30 minutes"
        case .oneHour:
            return "Starting in 1 hour"
        }
    }

    private func createRecurringContent(for task: TaskItem) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = "It's time for your scheduled task"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_RECURRING"
        content.userInfo = [
            "taskId": task.id.uuidString,
            "type": "recurring"
        ]
        return content
    }

    private func scheduleNotification(
        identifier: String,
        content: UNMutableNotificationContent,
        trigger: UNNotificationTrigger
    ) async {
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling task notification: \(error)")
        }
    }

    // MARK: - Notification Categories

    func registerNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK_ACTION",
            title: "Complete",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TASK_ACTION",
            title: "Snooze 15 min",
            options: []
        )

        let reminderCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let recurringCategory = UNNotificationCategory(
            identifier: "TASK_RECURRING",
            actions: [completeAction],
            intentIdentifiers: [],
            options: []
        )

        // Get existing categories and add ours
        UNUserNotificationCenter.current().getNotificationCategories { existingCategories in
            var categories = existingCategories
            categories.insert(reminderCategory)
            categories.insert(recurringCategory)
            UNUserNotificationCenter.current().setNotificationCategories(categories)
        }
    }

    // MARK: - Pending Notifications

    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openTaskDetail = Notification.Name("openTaskDetail")
}
