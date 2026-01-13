import SwiftUI
import SwiftData

@Observable
final class TaskStore {
    private var modelContext: ModelContext?
    var tasks: [TaskItem] = []
    var completionRecords: [TaskCompletionRecord] = []
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
            fetchCompletionRecords()
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchTasks()
        fetchCompletionRecords()
    }

    private func fetchTasks() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.startTime)])
        tasks = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchCompletionRecords() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<TaskCompletionRecord>(sortBy: [SortDescriptor(\.completedDate)])
        completionRecords = (try? modelContext.fetch(descriptor)) ?? []
    }

    func save() {
        try? modelContext?.save()
    }

    // MARK: - Computed Properties (Original TaskItem arrays)

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
        let instances = instancesForSelectedDate
        let total = instances.count
        guard total > 0 else { return 0 }
        let completed = instances.filter { $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    var totalEnergyForSelectedDate: Int {
        instancesForSelectedDate.reduce(0) { $0 + $1.energyLevel }
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

    // MARK: - Virtual Instance Computed Properties

    /// All task instances for the selected date, including recurring task expansions
    var instancesForSelectedDate: [VirtualTaskInstance] {
        var instances: [VirtualTaskInstance] = []

        for task in tasks {
            let isRecurring = RecurringTaskGenerator.isRecurring(task)

            if isRecurring {
                // Check if this recurring task occurs on the selected date
                if let instance = RecurringTaskGenerator.generateOccurrencesForDate(
                    task: task,
                    date: selectedDate,
                    completionRecords: completionRecords
                ) {
                    instances.append(instance)
                }
            } else {
                // Non-recurring task - only include if it's on the selected date
                if task.startTime.isSameDay(as: selectedDate) {
                    instances.append(VirtualTaskInstance(task: task))
                }
            }
        }

        return instances.sorted { $0.startTime < $1.startTime }
    }

    /// All task instances for the current week, grouped by day
    var instancesForWeek: [[VirtualTaskInstance]] {
        let calendar = Calendar.current
        let weekStart = selectedDate.startOfWeek

        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
            return instancesForDate(date)
        }
    }

    /// Get task instances for a specific date
    func instancesForDate(_ date: Date) -> [VirtualTaskInstance] {
        var instances: [VirtualTaskInstance] = []

        for task in tasks {
            let isRecurring = RecurringTaskGenerator.isRecurring(task)

            if isRecurring {
                if let instance = RecurringTaskGenerator.generateOccurrencesForDate(
                    task: task,
                    date: date,
                    completionRecords: completionRecords
                ) {
                    instances.append(instance)
                }
            } else {
                if task.startTime.isSameDay(as: date) {
                    instances.append(VirtualTaskInstance(task: task))
                }
            }
        }

        return instances.sorted { $0.startTime < $1.startTime }
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
        let weekInstances = instancesForWeek.flatMap { $0 }
        let total = weekInstances.count
        guard total > 0 else { return 0 }
        let completed = weekInstances.filter { $0.isCompleted }.count
        return Double(completed) / Double(total)
    }

    // MARK: - Methods

    func toggleCompletion(for task: TaskItem) {
        task.toggleCompletion()
        try? modelContext?.save()
        HapticManager.shared.taskCompleted()
    }

    /// Toggle completion for a virtual task instance
    func toggleCompletion(for instance: VirtualTaskInstance) {
        if instance.isVirtual {
            // For virtual instances, we need to create/remove a completion record
            let calendar = Calendar.current

            if instance.isCompleted {
                // Remove the completion record
                if let record = completionRecords.first(where: { record in
                    record.taskId == instance.sourceTask.id &&
                    calendar.isDate(record.completedDate, inSameDayAs: instance.instanceDate)
                }) {
                    modelContext?.delete(record)
                    completionRecords.removeAll { $0.id == record.id }
                }
            } else {
                // Create a new completion record
                let record = TaskCompletionRecord(
                    taskId: instance.sourceTask.id,
                    completedDate: instance.instanceDate
                )
                modelContext?.insert(record)
                completionRecords.append(record)
            }
        } else {
            // For non-virtual instances, toggle the source task directly
            instance.sourceTask.toggleCompletion()
        }

        try? modelContext?.save()
        HapticManager.shared.taskCompleted()
    }

    /// Check if a virtual instance is completed
    func isInstanceCompleted(_ instance: VirtualTaskInstance) -> Bool {
        if instance.isVirtual {
            let calendar = Calendar.current
            return completionRecords.contains { record in
                record.taskId == instance.sourceTask.id &&
                calendar.isDate(record.completedDate, inSameDayAs: instance.instanceDate)
            }
        } else {
            return instance.sourceTask.isCompleted
        }
    }

    func deleteTask(_ task: TaskItem) {
        HapticManager.shared.deleted()
        // Also remove all completion records for this task
        let recordsToDelete = completionRecords.filter { $0.taskId == task.id }
        for record in recordsToDelete {
            modelContext?.delete(record)
        }
        completionRecords.removeAll { $0.taskId == task.id }

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
