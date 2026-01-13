import SwiftUI
import SwiftData
import UserNotifications

@main
struct FocalApp: App {
    init() {
        // Register notification delegate and categories on app launch
        UNUserNotificationCenter.current().delegate = TodoNotificationDelegate.shared
        TodoNotificationService.shared.registerNotificationCategories()
        TaskNotificationService.shared.registerNotificationCategories()

        // Request notification authorization
        Task {
            await TodoNotificationService.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TaskItem.self, Subtask.self, TodoItem.self, TodoSubtask.self, TaskCompletionRecord.self])
    }
}
