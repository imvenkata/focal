import Foundation
import UserNotifications
import SwiftUI

@Observable
final class TodoNotificationService {
    static let shared = TodoNotificationService()

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

    func scheduleReminder(for todo: TodoItem) async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }

        // Remove existing notifications for this todo
        await removeReminder(for: todo)

        // Check if reminder is set
        guard let reminderOption = todo.reminderOption,
              reminderOption != "None",
              let option = TodoReminderOption(rawValue: reminderOption),
              let timeInterval = option.timeInterval else {
            return
        }

        // Calculate notification date
        guard let notificationDate = calculateNotificationDate(for: todo, offset: timeInterval) else {
            return
        }

        // Don't schedule if the date is in the past
        guard notificationDate > Date() else { return }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = todo.title
        content.body = createNotificationBody(for: todo, option: option)
        content.sound = .default
        content.badge = 1

        // Add category for actions
        content.categoryIdentifier = "TODO_REMINDER"

        // Add user info
        content.userInfo = [
            "todoId": todo.id.uuidString,
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
            identifier: "todo-reminder-\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled reminder for '\(todo.title)' at \(notificationDate)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    func removeReminder(for todo: TodoItem) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["todo-reminder-\(todo.id.uuidString)"]
        )
    }

    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Recurring Notifications

    func scheduleRecurringReminders(for todo: TodoItem) async {
        guard isAuthorized else { return }

        // Remove existing
        await removeReminder(for: todo)

        guard let recurrenceOption = todo.recurrenceOption,
              recurrenceOption != "None",
              let option = TodoRecurrenceOption(rawValue: recurrenceOption) else {
            return
        }

        // Handle different recurrence types
        switch option {
        case .none:
            break
        case .daily:
            await scheduleDailyReminder(for: todo)
        case .weekly:
            await scheduleWeeklyReminder(for: todo)
        case .biweekly:
            await scheduleBiweeklyReminder(for: todo)
        case .monthly:
            await scheduleMonthlyReminder(for: todo)
        case .yearly:
            await scheduleYearlyReminder(for: todo)
        case .custom:
            await scheduleCustomReminder(for: todo)
        }
    }

    private func scheduleDailyReminder(for todo: TodoItem) async {
        guard let time = todo.dueTime ?? todo.dueDate else { return }

        let content = createRecurringContent(for: todo)
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "todo-daily-\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleWeeklyReminder(for todo: TodoItem) async {
        guard let dueDate = todo.dueDate else { return }

        let content = createRecurringContent(for: todo)
        var components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: dueDate)
        if let time = todo.dueTime {
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "todo-weekly-\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleBiweeklyReminder(for todo: TodoItem) async {
        // For biweekly, we schedule individual notifications for the next 8 occurrences
        guard let dueDate = todo.dueDate else { return }

        for i in 0..<8 {
            guard let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: i * 2, to: dueDate) else {
                continue
            }

            let content = createRecurringContent(for: todo)
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            if let time = todo.dueTime {
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            await scheduleNotification(
                identifier: "todo-biweekly-\(todo.id.uuidString)-\(i)",
                content: content,
                trigger: trigger
            )
        }
    }

    private func scheduleMonthlyReminder(for todo: TodoItem) async {
        guard let dueDate = todo.dueDate else { return }

        let content = createRecurringContent(for: todo)
        var components = Calendar.current.dateComponents([.day, .hour, .minute], from: dueDate)
        if let time = todo.dueTime {
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "todo-monthly-\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleYearlyReminder(for todo: TodoItem) async {
        guard let dueDate = todo.dueDate else { return }

        let content = createRecurringContent(for: todo)
        var components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: dueDate)
        if let time = todo.dueTime {
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        await scheduleNotification(
            identifier: "todo-yearly-\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )
    }

    private func scheduleCustomReminder(for todo: TodoItem) async {
        guard !todo.repeatDays.isEmpty else { return }

        let time = todo.dueTime ?? Date()
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)

        for day in todo.repeatDays {
            let content = createRecurringContent(for: todo)
            var components = DateComponents()
            components.weekday = day + 1 // Calendar weekdays are 1-7, our days are 0-6
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            await scheduleNotification(
                identifier: "todo-custom-\(todo.id.uuidString)-\(day)",
                content: content,
                trigger: trigger
            )
        }
    }

    // MARK: - Helpers

    private func calculateNotificationDate(for todo: TodoItem, offset: TimeInterval) -> Date? {
        guard let dueDate = todo.dueDate else { return nil }

        let calendar = Calendar.current
        var notificationDate: Date

        if todo.hasDueTime, let dueTime = todo.dueTime {
            // Combine due date and time
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)

            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute

            guard let fullDate = calendar.date(from: combined) else { return nil }
            notificationDate = fullDate
        } else {
            // Use start of day for date-only todos
            notificationDate = calendar.startOfDay(for: dueDate)
            // Default to 9 AM if no time specified
            notificationDate = calendar.date(byAdding: .hour, value: 9, to: notificationDate) ?? notificationDate
        }

        // Subtract the reminder offset
        return notificationDate.addingTimeInterval(-offset)
    }

    private func createNotificationBody(for todo: TodoItem, option: TodoReminderOption) -> String {
        switch option {
        case .none:
            return ""
        case .atTime:
            return "It's time for your todo"
        case .fiveMin:
            return "Starting in 5 minutes"
        case .fifteenMin:
            return "Starting in 15 minutes"
        case .thirtyMin:
            return "Starting in 30 minutes"
        case .oneHour:
            return "Starting in 1 hour"
        case .oneDay:
            return "Due tomorrow"
        }
    }

    private func createRecurringContent(for todo: TodoItem) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = todo.title
        content.body = "Recurring todo reminder"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TODO_RECURRING"
        content.userInfo = [
            "todoId": todo.id.uuidString,
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
            print("Error scheduling notification: \(error)")
        }
    }

    // MARK: - Notification Categories

    func registerNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Complete",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 15 min",
            options: []
        )

        let reminderCategory = UNNotificationCategory(
            identifier: "TODO_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let recurringCategory = UNNotificationCategory(
            identifier: "TODO_RECURRING",
            actions: [completeAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            reminderCategory,
            recurringCategory
        ])
    }

    // MARK: - Badge Management

    func updateBadgeCount(with count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Pending Notifications

    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    func getDeliveredNotifications() async -> [UNNotification] {
        await UNUserNotificationCenter.current().deliveredNotifications()
    }
}

// MARK: - Notification Handler

class TodoNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = TodoNotificationDelegate()

    var onComplete: ((String) -> Void)?
    var onSnooze: ((String) -> Void)?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let todoId = userInfo["todoId"] as? String else {
            completionHandler()
            return
        }

        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
            onComplete?(todoId)
        case "SNOOZE_ACTION":
            onSnooze?(todoId)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification - open detail view
            NotificationCenter.default.post(
                name: .openTodoDetail,
                object: nil,
                userInfo: ["todoId": todoId]
            )
        default:
            break
        }

        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openTodoDetail = Notification.Name("openTodoDetail")
}
