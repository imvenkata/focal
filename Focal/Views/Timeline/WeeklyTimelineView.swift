import SwiftUI

struct WeeklyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var selectedTask: TaskItem?

    private let timelineStartHour = 6
    private let timelineEndHour = 23
    private var hourHeight: CGFloat {
        DS.Sizes.weekTimelineHeight / CGFloat(timelineEndHour - timelineStartHour)
    }
    private let gridStride = 3

    var body: some View {
        VStack(spacing: 0) {
            WeeklyMiniStatsBar(
                energy: taskStore.totalEnergyForSelectedDate,
                completed: taskStore.tasksForWeek.flatMap { $0 }.filter { $0.isCompleted }.count,
                total: taskStore.tasksForWeek.flatMap { $0 }.count,
                progress: taskStore.currentWeekProgress
            )
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.md)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Time grid with tasks
                    HStack(alignment: .top, spacing: 0) {
                        // Time labels
                        ZStack(alignment: .topTrailing) {
                            ForEach(majorHours, id: \.self) { hour in
                                WeekTimeLabel(hour: hour)
                                    .offset(y: CGFloat(hour - timelineStartHour) * hourHeight)
                            }
                        }
                        .frame(width: DS.Sizes.timeLabelWidth, height: totalTimelineHeight, alignment: .topTrailing)
                        .padding(.trailing, DS.Spacing.sm)

                        // Day columns
                        HStack(spacing: DS.Spacing.xs) {
                            ForEach(Array(taskStore.weekDates.enumerated()), id: \.offset) { index, date in
                                DayColumn(
                                    date: date,
                                    tasks: taskStore.tasksForWeek[index],
                                    isSelected: date.isSameDay(as: taskStore.selectedDate),
                                    hourHeight: hourHeight,
                                    startHour: timelineStartHour,
                                    endHour: timelineEndHour,
                                    gridStride: gridStride,
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
                                .padding(.leading, DS.Sizes.timeLabelWidth + DS.Spacing.sm)
                                .offset(y: currentTimeOffset)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .padding(.vertical, DS.Spacing.md)

                Text("Tap a day to see details")
                    .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.stone400)
                    .padding(.top, DS.Spacing.md)
                    .padding(.bottom, DS.Spacing.lg)
            }
        }
        .transition(.opacity)
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environment(taskStore)
        }
    }

    private var majorHours: [Int] {
        Array(stride(from: timelineStartHour, to: timelineEndHour, by: gridStride))
    }

    private var totalTimelineHeight: CGFloat {
        CGFloat(timelineEndHour - timelineStartHour) * hourHeight
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
    let gridStride: Int
    let onTaskTap: (TaskItem) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Grid lines
            ForEach(gridHours, id: \.self) { hour in
                Rectangle()
                    .fill(DS.Colors.stone200)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .offset(y: CGFloat(hour - startHour) * hourHeight)
            }
            
            // Vertical solid line connecting tasks
            if tasks.count > 1 {
                // Sort tasks by time to ensure correct line positioning
                let sortedTasks = tasks.sorted { $0.startTime < $1.startTime }
                let firstTask = sortedTasks.first!
                let lastTask = sortedTasks.last!
                
                // First task position (line starts at the top of the capsule)
                let firstTaskTime = Double(firstTask.startTime.hour) + Double(firstTask.startTime.minute) / 60.0
                let firstTaskOffset = CGFloat(firstTaskTime - Double(startHour)) * hourHeight
                
                // Last task end position (ensures the capsule is covered even for short durations)
                let lastTaskStartTime = Double(lastTask.startTime.hour) + Double(lastTask.startTime.minute) / 60.0
                let lastTaskStartOffset = CGFloat(lastTaskStartTime - Double(startHour)) * hourHeight
                let lastTaskEndTime = Double(lastTask.endTime.hour) + Double(lastTask.endTime.minute) / 60.0
                let lastTaskEndOffset = CGFloat(lastTaskEndTime - Double(startHour)) * hourHeight
                let lastTaskBottomOffset = max(lastTaskEndOffset, lastTaskStartOffset + DS.Sizes.glassCapsuleHeight)
                
                // Track height spans from first task to last task bottom
                let trackHeight = max(lastTaskBottomOffset - firstTaskOffset, DS.Sizes.glassCapsuleHeight)
                
                GlassStemView(height: trackHeight)
                    .offset(y: firstTaskOffset)
                    .opacity(date.isToday ? 0.9 : 0.7)
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
        .frame(height: totalTimelineHeight, alignment: .top)
        .background(Color.clear)
    }

    private var gridHours: [Int] {
        Array(stride(from: startHour, to: endHour, by: gridStride))
    }

    private var totalTimelineHeight: CGFloat {
        CGFloat(endHour - startHour) * hourHeight
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
        .accessibilityHint("Double tap to view task details")
        .offset(y: yOffset)
    }

    private var yOffset: CGFloat {
        let taskHour = task.startTime.hour
        let taskMinute = task.startTime.minute
        let hoursSinceStart = CGFloat(taskHour - startHour) + CGFloat(taskMinute) / 60.0
        return hoursSinceStart * hourHeight
    }
}

// MARK: - Week Time Label
private struct WeekTimeLabel: View {
    let hour: Int

    var body: some View {
        Text(String(format: "%02d", hour))
            .scaledFont(size: 9, weight: .medium, design: .monospaced, relativeTo: .caption2)
            .foregroundStyle(DS.Colors.stone400)
            .frame(width: DS.Sizes.timeLabelWidth, alignment: .trailing)
    }
}

// MARK: - Weekly Mini Stats
private struct WeeklyMiniStatsBar: View {
    let energy: Int
    let completed: Int
    let total: Int
    let progress: Double

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.xs) {
                Text("🔥")
                    .scaledFont(size: 12, relativeTo: .caption)
                Text("\(energy)")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.stone700)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.xs)
            .background(DS.Colors.cardBackground.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.pill)
                    .stroke(DS.Colors.stone200.opacity(0.6), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DS.Colors.stone200)
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DS.Colors.emerald500, DS.Colors.teal500],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(completed)/\(total)")
                .scaledFont(size: 10, weight: .medium, design: .monospaced, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.stone500)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completed) of \(total) tasks completed this week")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#Preview {
    WeeklyTimelineView()
        .environment(TaskStore())
}
