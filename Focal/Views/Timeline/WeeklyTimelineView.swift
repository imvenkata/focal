import SwiftUI

struct WeeklyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var selectedTask: TaskItem?

    private let timelineStartHour = 6
    private let timelineEndHour = 23
    private let hourHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressBar(
                progress: taskStore.currentWeekProgress,
                completed: taskStore.tasksForWeek.flatMap { $0 }.filter { $0.isCompleted }.count,
                total: taskStore.tasksForWeek.flatMap { $0 }.count
            )
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.md)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Time grid with tasks
                    HStack(alignment: .top, spacing: 0) {
                        // Time labels
                        VStack(spacing: 0) {
                            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                                TimeLabel(hour: hour)
                                    .frame(height: hourHeight, alignment: .top)
                            }
                        }
                        .padding(.trailing, DS.Spacing.sm)

                        // Day columns
                        HStack(spacing: 2) {
                            ForEach(Array(taskStore.weekDates.enumerated()), id: \.offset) { index, date in
                                DayColumn(
                                    date: date,
                                    tasks: taskStore.tasksForWeek[index],
                                    isSelected: date.isSameDay(as: taskStore.selectedDate),
                                    hourHeight: hourHeight,
                                    startHour: timelineStartHour,
                                    endHour: timelineEndHour,
                                    onTaskTap: { task in
                                        selectedTask = task
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)

                    // Current time indicator overlay
                    .overlay(alignment: .topLeading) {
                        if shouldShowCurrentTimeIndicator {
                            CurrentTimeIndicator()
                                .padding(.leading, 48)
                                .offset(y: currentTimeOffset)
                        }
                    }
                }
                .padding(.vertical, DS.Spacing.md)
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environment(taskStore)
        }
    }

    private var shouldShowCurrentTimeIndicator: Bool {
        let hour = Date().hour
        return hour >= timelineStartHour && hour < timelineEndHour &&
               taskStore.selectedDate.isSameWeek(as: Date())
    }

    private var currentTimeOffset: CGFloat {
        let now = Date()
        let hour = now.hour
        let minute = now.minute
        let hoursSinceStart = CGFloat(hour - timelineStartHour) + CGFloat(minute) / 60.0
        return hoursSinceStart * hourHeight
    }
}

// MARK: - Day Column
struct DayColumn: View {
    let date: Date
    let tasks: [TaskItem]
    let isSelected: Bool
    let hourHeight: CGFloat
    let startHour: Int
    let endHour: Int
    let onTaskTap: (TaskItem) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Grid lines
            VStack(spacing: 0) {
                ForEach(startHour..<endHour, id: \.self) { _ in
                    Rectangle()
                        .fill(DS.Colors.divider.opacity(0.5))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: hourHeight, alignment: .top)
                }
            }
            
            // Vertical solid line connecting tasks
            if tasks.count > 1 {
                let trackColor = date.isToday ? DS.Colors.divider : DS.Colors.divider.opacity(0.6)
                
                // Sort tasks by time to ensure correct line positioning
                let sortedTasks = tasks.sorted { $0.startTime < $1.startTime }
                let firstTask = sortedTasks.first!
                let lastTask = sortedTasks.last!
                
                // First task center position (pill center = top + half pill height)
                let firstTaskTime = Double(firstTask.startTime.hour) + Double(firstTask.startTime.minute) / 60.0
                let firstTaskOffset = CGFloat(firstTaskTime - Double(startHour)) * hourHeight + 18 // +18 for pill center (36/2)
                
                // Last task end position (includes task duration + pill + duration bar)
                let lastTaskEndTime = Double(lastTask.startTime.hour) + Double(lastTask.startTime.minute) / 60.0 + Double(lastTask.duration) / 3600.0
                let lastTaskEndOffset = CGFloat(lastTaskEndTime - Double(startHour)) * hourHeight
                
                // Track height spans from first task center to last task end
                let trackHeight = max(lastTaskEndOffset - firstTaskOffset, 36) // Minimum height of one pill
                
                Rectangle()
                    .fill(trackColor)
                    .frame(width: 1, height: trackHeight)
                    .offset(y: firstTaskOffset)
            }

            // Task pins
            ForEach(tasks) { task in
                TaskPinPosition(
                    task: task,
                    hourHeight: hourHeight,
                    startHour: startHour,
                    onTap: { onTaskTap(task) }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .background(isSelected ? DS.Colors.sky.opacity(0.05) : Color.clear)
    }
}

// MARK: - Task Pin Position
struct TaskPinPosition: View {
    let task: TaskItem
    let hourHeight: CGFloat
    let startHour: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            MiniTaskPin(task: task, hourHeight: hourHeight)
        }
        .buttonStyle(.plain)
        .offset(y: yOffset)
    }

    private var yOffset: CGFloat {
        let taskHour = task.startTime.hour
        let taskMinute = task.startTime.minute
        let hoursSinceStart = CGFloat(taskHour - startHour) + CGFloat(taskMinute) / 60.0
        return hoursSinceStart * hourHeight
    }
}

#Preview {
    WeeklyTimelineView()
        .environment(TaskStore())
}
