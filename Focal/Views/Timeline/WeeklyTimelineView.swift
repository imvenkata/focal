import SwiftUI

// MARK: - Column Frame Preference Key
private struct ColumnFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct WeeklyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @Environment(TaskDragState.self) private var dragState
    var onTaskTap: (TaskItem) -> Void = { _ in }

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
                                    columnIndex: index,
                                    onTaskTap: onTaskTap
                                )
                            }
                        }
                        .coordinateSpace(name: "weekColumns")
                        .onPreferenceChange(ColumnFramePreferenceKey.self) { frames in
                            for (index, frame) in frames {
                                dragState.registerColumnFrame(index: index, frame: frame)
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

                    // Dragged capsule overlay
                    .overlay {
                        if dragState.isDragging, let task = dragState.draggedTask {
                            DraggedCapsuleOverlay(task: task, hourHeight: hourHeight)
                        }
                    }
                }
                .padding(.vertical, DS.Spacing.md)

                Text(dragState.isDragging ? "Release to move task" : "Hold a task to drag")
                    .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(dragState.isDragging ? DS.Colors.sage : DS.Colors.stone400)
                    .padding(.top, DS.Spacing.md)
                    .padding(.bottom, DS.Spacing.lg)
                    .animation(DS.Animation.quick, value: dragState.isDragging)
            }
        }
        .transition(.opacity)
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
    @Environment(TaskStore.self) private var taskStore
    @Environment(TaskDragState.self) private var dragState

    let date: Date
    let tasks: [TaskItem]
    let isSelected: Bool
    let hourHeight: CGFloat
    let startHour: Int
    let endHour: Int
    let gridStride: Int
    let columnIndex: Int
    let onTaskTap: (TaskItem) -> Void

    private var isDropTarget: Bool {
        dragState.isTargetColumn(columnIndex)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Drop target highlight background
            if isDropTarget {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(DS.Colors.sage.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(DS.Colors.sage.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

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

                GlassStemView(
                    height: trackHeight,
                    accentColor: date.isToday ? DS.Colors.stone400 : DS.Colors.stone300
                )
                .offset(y: firstTaskOffset)
                .opacity(date.isToday ? 0.95 : 0.8)
            }

            // Task pins
            ForEach(tasks) { task in
                TaskPinPosition(
                    task: task,
                    hourHeight: hourHeight,
                    startHour: startHour,
                    columnIndex: columnIndex,
                    onTap: { onTaskTap(task) },
                    onDrop: { droppedTask, targetIndex, hour, minute in
                        withAnimation(DS.Animation.spring) {
                            taskStore.moveTaskToWeekDay(droppedTask, dayIndex: targetIndex, hour: hour, minute: minute)
                        }
                    }
                )
                .opacity(dragState.isDraggedTask(task) ? 0.3 : 1)
            }

            // Drop target badge
            if isDropTarget {
                VStack {
                    Spacer()
                    DropTargetBadge(
                        dayName: date.shortWeekdayName,
                        time: dragState.formattedTargetTime
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .padding(.bottom, DS.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: totalTimelineHeight, alignment: .top)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ColumnFramePreferenceKey.self, value: [columnIndex: geo.frame(in: .global)])
            }
        )
        .animation(DS.Animation.quick, value: isDropTarget)
    }

    private var gridHours: [Int] {
        Array(stride(from: startHour, to: endHour, by: gridStride))
    }

    private var totalTimelineHeight: CGFloat {
        CGFloat(endHour - startHour) * hourHeight
    }
}

// MARK: - Drop Target Badge
private struct DropTargetBadge: View {
    let dayName: String
    let time: String

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text(dayName)
                    .scaledFont(size: 11, weight: .semibold, relativeTo: .caption2)
            }

            Text(time)
                .scaledFont(size: 13, weight: .bold, design: .monospaced, relativeTo: .caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(DS.Colors.sage)
                .shadow(color: DS.Colors.sage.opacity(0.4), radius: 8, y: 4)
        )
    }
}

// MARK: - Task Pin Position
struct TaskPinPosition: View {
    @Environment(TaskDragState.self) private var dragState
    @State private var dragStartTime: Date? = nil
    @State private var hasActivatedDrag = false
    @State private var initialLocation: CGPoint = .zero

    let task: TaskItem
    let hourHeight: CGFloat
    let startHour: Int
    let columnIndex: Int
    let onTap: () -> Void
    var onDrop: ((TaskItem, Int, Int, Int) -> Void)? = nil  // task, dayIndex, hour, minute

    private let longPressThreshold: TimeInterval = 0.2
    private let dragDistanceThreshold: CGFloat = 5

    private var isDragging: Bool {
        dragState.isDraggedTask(task)
    }

    private var isRoutineMarker: Bool {
        task.isRoutine
    }

    var body: some View {
        MiniTaskPin(task: task, hourHeight: hourHeight)
            .scaleEffect(hasActivatedDrag || isDragging ? 1.15 : 1.0)
            .rotationEffect(isDragging ? shakeRotation : .zero)
            .shadow(
                color: isDragging ? task.color.color.opacity(0.5) : .clear,
                radius: isDragging ? 20 : 0,
                y: isDragging ? 10 : 0
            )
            .offset(y: yOffset)
            .animation(isDragging ? shakeAnimation : DS.Animation.bounce, value: isDragging)
            .animation(DS.Animation.bounce, value: hasActivatedDrag)
            .gesture(isRoutineMarker ? nil : dragGesture)
            .accessibilityHint(isRoutineMarker ? "Routine marker" : "Hold to drag, tap to preview")
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                // First touch - record start time and location
                if dragStartTime == nil {
                    dragStartTime = Date()
                    initialLocation = value.startLocation
                }

                guard let startTime = dragStartTime else { return }
                let elapsed = Date().timeIntervalSince(startTime)
                let distance = hypot(
                    value.location.x - initialLocation.x,
                    value.location.y - initialLocation.y
                )

                // Activate drag mode after holding for threshold time
                if !hasActivatedDrag && elapsed >= longPressThreshold {
                    hasActivatedDrag = true
                    dragState.startDrag(task: task, columnIndex: columnIndex, location: value.location)
                }

                // Update drag location if in drag mode
                if hasActivatedDrag {
                    dragState.updateDrag(location: value.location)
                }
            }
            .onEnded { value in
                let startTime = dragStartTime
                let wasActivated = hasActivatedDrag

                // Reset local state
                dragStartTime = nil
                hasActivatedDrag = false

                // If drag was activated, try to complete the drop
                if wasActivated {
                    if let result = dragState.endDrag() {
                        onDrop?(result.task, result.toIndex, result.toHour, result.toMinute)
                    }
                } else if let startTime = startTime {
                    // Short tap - trigger onTap
                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed < longPressThreshold {
                        onTap()
                    } else {
                        // Long press but no movement - cancel
                        dragState.cancelDrag()
                    }
                }
            }
    }

    private var shakeRotation: Angle {
        .degrees(sin(Date().timeIntervalSinceReferenceDate * 25) * 2)
    }

    private var shakeAnimation: Animation {
        Animation.linear(duration: 0.1).repeatForever(autoreverses: true)
    }

    private var yOffset: CGFloat {
        let taskHour = task.startTime.hour
        let taskMinute = task.startTime.minute
        let hoursSinceStart = CGFloat(taskHour - startHour) + CGFloat(taskMinute) / 60.0
        return hoursSinceStart * hourHeight
    }
}

// MARK: - Dragged Capsule Overlay
struct DraggedCapsuleOverlay: View {
    @Environment(TaskDragState.self) private var dragState
    let task: TaskItem
    let hourHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            MiniTaskPin(task: task, hourHeight: hourHeight)
                .scaleEffect(1.2)
                .rotationEffect(.degrees(sin(Date().timeIntervalSinceReferenceDate * 25) * 2.5))
                .shadow(color: task.color.color.opacity(0.6), radius: 24, y: 12)
                .shadow(color: Color.black.opacity(0.2), radius: 16, y: 8)
                .position(
                    x: dragState.dragLocation.x - geo.frame(in: .global).minX,
                    y: dragState.dragLocation.y - geo.frame(in: .global).minY
                )
                .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8), value: dragState.dragLocation)
        }
        .allowsHitTesting(false)
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
        .environment(TaskDragState())
}
