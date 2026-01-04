import Foundation

// MARK: - Preview Data
extension TaskItem {
    static var preview: TaskItem {
        let task = TaskItem(
            title: "Gym Workout",
            icon: "🏋️",
            colorName: "sage",
            startTime: Date(),
            duration: 3600,
            energyLevel: 4
        )
        task.addSubtask("Warm up - 10 min")
        task.addSubtask("Strength training")
        task.addSubtask("Cool down")
        return task
    }

    static var previewList: [TaskItem] {
        let calendar = Calendar.current
        let today = Date()

        let wakeUp = TaskItem(
            title: "Rise and Shine",
            icon: "☀️",
            colorName: "coral",
            startTime: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)!,
            duration: 30 * 60,
            isRoutine: true,
            energyLevel: 1
        )

        let gym = TaskItem(
            title: "Gym",
            icon: "🏋️",
            colorName: "sage",
            startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
            duration: 60 * 60,
            energyLevel: 4
        )

        let meeting = TaskItem(
            title: "Team Meeting",
            icon: "👥",
            colorName: "sky",
            startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!,
            duration: 60 * 60,
            energyLevel: 2
        )

        let windDown = TaskItem(
            title: "Wind Down",
            icon: "🌙",
            colorName: "lavender",
            startTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!,
            duration: 30 * 60,
            isRoutine: true,
            energyLevel: 0
        )

        return [wakeUp, gym, meeting, windDown]
    }
}

extension TaskStore {
    static var preview: TaskStore {
        let store = TaskStore()
        store.loadSampleData()
        return store
    }
}
