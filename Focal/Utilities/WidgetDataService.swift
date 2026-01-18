import Foundation
import WidgetKit

/// Service to sync task data with the widget via App Groups
final class WidgetDataService {
    static let shared = WidgetDataService()

    private let appGroupIdentifier = "group.com.focal.app"
    private let tasksKey = "widgetTasks"
    private let completedCountKey = "widgetCompletedCount"
    private let totalCountKey = "widgetTotalCount"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Public Methods

    /// Update widget with current tasks for today
    func updateWidget(with tasks: [TaskItem]) {
        let todayTasks = tasks.filter { $0.startTime.isSameDay(as: Date()) }
            .sorted { $0.startTime < $1.startTime }

        let widgetTasks = todayTasks.map { task in
            WidgetTaskData(
                id: task.id,
                title: task.title,
                icon: task.icon,
                colorHex: task.color.hexString,
                startTime: task.startTime,
                isCompleted: task.isCompleted
            )
        }

        saveTasks(widgetTasks)
        saveCompletedCount(todayTasks.filter { $0.isCompleted }.count)
        saveTotalCount(todayTasks.count)

        // Request widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "TodayTasksWidget")
    }

    /// Update widget after task completion toggle
    func updateWidgetAfterCompletion(tasks: [TaskItem]) {
        updateWidget(with: tasks)
    }

    /// Force refresh all widgets
    func refreshAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Private Methods

    private func saveTasks(_ tasks: [WidgetTaskData]) {
        guard let sharedDefaults else { return }

        if let data = try? JSONEncoder().encode(tasks) {
            sharedDefaults.set(data, forKey: tasksKey)
        }
    }

    private func saveCompletedCount(_ count: Int) {
        sharedDefaults?.set(count, forKey: completedCountKey)
    }

    private func saveTotalCount(_ count: Int) {
        sharedDefaults?.set(count, forKey: totalCountKey)
    }
}

// MARK: - Widget Task Data (Codable for sharing)

struct WidgetTaskData: Codable {
    let id: UUID
    let title: String
    let icon: String
    let colorHex: String
    let startTime: Date
    let isCompleted: Bool
}

// MARK: - TaskColor Extension

extension TaskColor {
    var hexString: String {
        switch self {
        case .sage: return "#8BC34A"
        case .sky: return "#03A9F4"
        case .lavender: return "#9C27B0"
        case .coral: return "#FF5722"
        case .amber: return "#FFC107"
        case .rose: return "#E91E63"
        case .mint: return "#00BCD4"
        case .peach: return "#FF9800"
        case .ocean: return "#3F51B5"
        case .slate: return "#607D8B"
        }
    }
}
