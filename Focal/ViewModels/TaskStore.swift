import SwiftUI
import SwiftData

@Observable
final class TaskStore {
    private var modelContext: ModelContext?
    var tasks: [TaskItem] = []
    var selectedDate: Date = Date()
    var viewMode: ViewMode = .day

    enum ViewMode {
        case week
        case day
    }

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        if modelContext != nil {
            fetchTasks()
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchTasks()
    }

    private func fetchTasks() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.startTime)])
        tasks = (try? modelContext.fetch(descriptor)) ?? []
    }

    func save() {
        try? modelContext?.save()
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
            let dayTasks = tasks.filter { $0.startTime.isSameDay(as: date) }
            return dayTasks.sorted { $0.startTime < $1.startTime }
        }
    }

    // MARK: - Day Markers

    private func dayMarkers(for date: Date) -> [TaskItem] {
        let calendar = Calendar.current

        let riseAndShine = TaskItem(
            title: "Rise & Shine",
            icon: "☀️",
            colorName: "amber",
            startTime: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: date)!,
            duration: 15 * 60,
            recurrenceOption: "Daily",
            energyLevel: 1
        )

        let windDown = TaskItem(
            title: "Wind Down",
            icon: "🌙",
            colorName: "lavender",
            startTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date)!,
            duration: 15 * 60,
            recurrenceOption: "Daily",
            energyLevel: 0
        )

        return [riseAndShine, windDown]
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
        try? modelContext?.save()
        HapticManager.shared.taskCompleted()
    }

    func deleteTask(_ task: TaskItem) {
        HapticManager.shared.deleted()
        modelContext?.delete(task)
        try? modelContext?.save()
        tasks.removeAll { $0.id == task.id }
    }

    func addTask(_ task: TaskItem) {
        modelContext?.insert(task)
        try? modelContext?.save()
        tasks.append(task)
    }

    func moveTask(_ task: TaskItem, toDate newDate: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let calendar = Calendar.current
        let originalTime = calendar.dateComponents([.hour, .minute, .second], from: task.startTime)

        var newComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        newComponents.hour = originalTime.hour
        newComponents.minute = originalTime.minute
        newComponents.second = originalTime.second

        if let newStartTime = calendar.date(from: newComponents) {
            tasks[index].startTime = newStartTime
            try? modelContext?.save()
        }
    }

    func moveTask(_ task: TaskItem, toDate newDate: Date, hour: Int, minute: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let calendar = Calendar.current
        var newComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        newComponents.hour = hour
        newComponents.minute = minute
        newComponents.second = 0

        if let newStartTime = calendar.date(from: newComponents) {
            tasks[index].startTime = newStartTime
            try? modelContext?.save()
        }
    }

    func moveTaskToWeekDay(_ task: TaskItem, dayIndex: Int) {
        guard dayIndex >= 0 && dayIndex < 7 else { return }
        let targetDate = weekDates[dayIndex]
        moveTask(task, toDate: targetDate)
    }

    func moveTaskToWeekDay(_ task: TaskItem, dayIndex: Int, hour: Int, minute: Int) {
        guard dayIndex >= 0 && dayIndex < 7 else { return }
        let targetDate = weekDates[dayIndex]
        moveTask(task, toDate: targetDate, hour: hour, minute: minute)
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

    func setViewMode(_ mode: ViewMode) {
        guard viewMode != mode else { return }
        withAnimation(DS.Animation.spring) {
            viewMode = mode
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

        tasks = [gym, meeting, breakfast, coding]
    }
}
