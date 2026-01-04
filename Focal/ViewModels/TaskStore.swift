import SwiftUI
import SwiftData

@Observable
final class TaskStore {
    var tasks: [TaskItem] = []
    var selectedDate: Date = Date()
    var viewMode: ViewMode = .week

    enum ViewMode {
        case week
        case day
    }

    // MARK: - Computed Properties

    var tasksForSelectedDate: [TaskItem] {
        tasks.filter { $0.startTime.isSameDay(as: selectedDate) }
            .sorted { $0.startTime < $1.startTime }
    }

    var completedTasksForSelectedDate: [TaskItem] {
        tasksForSelectedDate.filter { $0.isCompleted }
    }

    var pendingTasksForSelectedDate: [TaskItem] {
        tasksForSelectedDate.filter { !$0.isCompleted }
    }

    var progressForSelectedDate: Double {
        let total = tasksForSelectedDate.count
        guard total > 0 else { return 0 }
        return Double(completedTasksForSelectedDate.count) / Double(total)
    }

    var totalEnergyForSelectedDate: Int {
        tasksForSelectedDate.reduce(0) { $0 + $1.energyLevel }
    }

    var tasksForWeek: [[TaskItem]] {
        let calendar = Calendar.current
        let weekStart = selectedDate.startOfWeek

        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
            return tasks.filter { $0.startTime.isSameDay(as: date) }
                .sorted { $0.startTime < $1.startTime }
        }
    }

    var weekDates: [Date] {
        let weekStart = selectedDate.startOfWeek
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var currentWeekProgress: Double {
        let weekTasks = tasksForWeek.flatMap { $0 }
        let total = weekTasks.count
        guard total > 0 else { return 0 }
        let completed = weekTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    // MARK: - Methods

    func toggleCompletion(for task: TaskItem) {
        task.toggleCompletion()
        HapticManager.shared.taskCompleted()
    }

    func deleteTask(_ task: TaskItem) {
        HapticManager.shared.deleted()
        tasks.removeAll { $0.id == task.id }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        HapticManager.shared.selection()
    }

    func selectToday() {
        selectedDate = Date()
    }

    func goToNextDay() {
        selectedDate = selectedDate.adding(days: 1)
        HapticManager.shared.selection()
    }

    func goToPreviousDay() {
        selectedDate = selectedDate.adding(days: -1)
        HapticManager.shared.selection()
    }

    func goToNextWeek() {
        selectedDate = selectedDate.adding(days: 7)
        HapticManager.shared.selection()
    }

    func goToPreviousWeek() {
        selectedDate = selectedDate.adding(days: -7)
        HapticManager.shared.selection()
    }

    func toggleViewMode() {
        withAnimation(DS.Animation.spring) {
            viewMode = viewMode == .week ? .day : .week
        }
        HapticManager.shared.selection()
    }

    func tasksAt(hour: Int, for date: Date) -> [TaskItem] {
        tasks.filter { task in
            task.startTime.isSameDay(as: date) &&
            task.startTime.hour == hour
        }.sorted { $0.startTime < $1.startTime }
    }

    func hasTasksAt(hour: Int, for date: Date) -> Bool {
        !tasksAt(hour: hour, for: date).isEmpty
    }

    // MARK: - Sample Data

    func loadSampleData() {
        let today = Date()
        let calendar = Calendar.current

        // Morning routine
        let wakeUp = TaskItem(
            title: "Rise and Shine",
            icon: "☀️",
            colorName: "coral",
            startTime: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)!,
            duration: 30 * 60,
            isRoutine: true,
            energyLevel: 1
        )

        // Gym
        let gym = TaskItem(
            title: "Gym",
            icon: "🏋️",
            colorName: "sage",
            startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
            duration: 60 * 60,
            energyLevel: 4
        )
        gym.addSubtask("Warm up - 10 min")
        gym.addSubtask("Strength training")
        gym.addSubtask("Cool down")

        // Work meeting
        let meeting = TaskItem(
            title: "Team Meeting",
            icon: "👥",
            colorName: "sky",
            startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!,
            duration: 60 * 60,
            energyLevel: 2
        )

        // Evening
        let windDown = TaskItem(
            title: "Wind Down",
            icon: "🌙",
            colorName: "lavender",
            startTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!,
            duration: 30 * 60,
            isRoutine: true,
            energyLevel: 0
        )

        // Tomorrow's tasks
        let tomorrow = today.adding(days: 1)

        let breakfast = TaskItem(
            title: "Breakfast",
            icon: "🍳",
            colorName: "amber",
            startTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow)!,
            duration: 30 * 60,
            energyLevel: 1
        )

        let coding = TaskItem(
            title: "Deep Work - Coding",
            icon: "💻",
            colorName: "sky",
            startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!,
            duration: 120 * 60,
            energyLevel: 3
        )

        tasks = [wakeUp, gym, meeting, windDown, breakfast, coding]
    }
}
