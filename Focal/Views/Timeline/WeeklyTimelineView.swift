import SwiftUI
import UIKit

// MARK: - Column Frame Preference Key
private struct ColumnFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private enum AutoScrollDirection {
    case up
    case down
}

struct WeeklyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @Environment(TaskDragState.self) private var dragState
    var onTaskTap: (TaskItem) -> Void = { _ in }
    @State private var scrollView: UIScrollView?

    private let timelineStartHour = 6
    private let timelineEndHour = 23
    private var hourHeight: CGFloat {
        DS.Sizes.weekTimelineHeight / CGFloat(timelineEndHour - timelineStartHour)
    }
    private let gridStride = 3
    // Auto-scroll configuration (timer managed via onChange)
    @State private var autoScrollTimer: Timer?
    private let autoScrollEdgeThreshold: CGFloat = DS.Spacing.xxxxl
    private let autoScrollMaxSpeed: CGFloat = DS.Sizes.weekTimelineHeight

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

                Text(dragState.isDragging ? "Drag to change day/time • Release to schedule" : "Hold & drag to reschedule")
                    .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(dragState.isDragging ? DS.Colors.accent : DS.Colors.textTertiary)
                    .padding(.top, DS.Spacing.md)
                    .padding(.bottom, DS.Spacing.lg)
                    .animation(DS.Animation.quick, value: dragState.isDragging)
            }
            .scrollDisabled(dragState.isDragging)
            .background(ScrollViewIntrospector { scrollView in
                self.scrollView = scrollView
            })
            .onChange(of: dragState.isDragging) { _, isDragging in
                if isDragging {
                    // Start auto-scroll timer only when dragging
                    autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                        handleAutoScrollTick()
                    }
                } else {
                    // Stop timer when not dragging to save CPU
                    autoScrollTimer?.invalidate()
                    autoScrollTimer = nil
                }
            }
            .onDisappear {
                autoScrollTimer?.invalidate()
                autoScrollTimer = nil
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

    private func handleAutoScrollTick() {
        guard dragState.isDragging, let scrollView else { return }

        let frame = scrollView.convert(scrollView.bounds, to: nil)
        let dragY = dragState.dragLocation.y
        let topTrigger = frame.minY + autoScrollEdgeThreshold
        let bottomTrigger = frame.maxY - autoScrollEdgeThreshold

        var direction: AutoScrollDirection?
        var intensity: CGFloat = 0

        if dragY < topTrigger {
            direction = .up
            intensity = min(1, (topTrigger - dragY) / autoScrollEdgeThreshold)
        } else if dragY > bottomTrigger {
            direction = .down
            intensity = min(1, (dragY - bottomTrigger) / autoScrollEdgeThreshold)
        }

        guard let direction else { return }

        let speed = autoScrollMaxSpeed * intensity
        let delta = speed * (1.0 / 60.0)
        let signedDelta = direction == .up ? -delta : delta

        let minOffset = -scrollView.adjustedContentInset.top
        let maxOffset = max(
            scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom,
            minOffset
        )

        let newOffset = min(max(scrollView.contentOffset.y + signedDelta, minOffset), maxOffset)

        guard abs(newOffset - scrollView.contentOffset.y) > 0.1 else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
        dragState.updateDrag(location: dragState.dragLocation)
    }
}

private struct ScrollViewIntrospector: UIViewRepresentable {
    let onResolve: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        resolveScrollView(from: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        resolveScrollView(from: uiView)
    }

    private func resolveScrollView(from view: UIView) {
        DispatchQueue.main.async {
            if let scrollView = view.findScrollView() {
                onResolve(scrollView)
            }
        }
    }
}

private extension UIView {
    func findScrollView() -> UIScrollView? {
        var current: UIView? = self

        while let view = current {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
            current = view.superview
        }

        return nil
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
            // Present day center vertical glow - Premium iPhone style
            if date.isToday {
                GeometryReader { geo in
                    ZStack {
                        // Outer glow
                        RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous)
                            .fill(DS.Colors.secondary.opacity(0.15))
                            .frame(width: 8)
                            .blur(radius: 8)

                        // Inner glow
                        RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous)
                            .fill(DS.Colors.secondary.opacity(0.25))
                            .frame(width: 3)
                            .blur(radius: 3)

                        // Core line
                        RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DS.Colors.secondary.opacity(0.4),
                                        DS.Colors.secondary.opacity(0.3),
                                        DS.Colors.secondary.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 1.5)
                    }
                    .frame(maxHeight: .infinity)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }

            // Drop target highlight background
            if isDropTarget {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(DS.Colors.accent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(DS.Colors.accent.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            // Drop zone preview - shows where task will land
            if isDropTarget, dragState.draggedTask != nil, let targetHour = dragState.targetHour {
                let targetMinute = dragState.targetMinute
                let hoursSinceStart = CGFloat(targetHour - startHour) + CGFloat(targetMinute) / 60.0
                let previewYOffset = hoursSinceStart * hourHeight

                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.accent.opacity(0.2))
                    .frame(width: DS.Sizes.glassCapsuleWidth, height: DS.Sizes.glassCapsuleHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(DS.Colors.accent.opacity(0.5), lineWidth: 1.5)
                    )
                    .offset(y: previewYOffset)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .animation(DS.Animation.quick, value: targetHour)
                    .animation(DS.Animation.quick, value: targetMinute)
            }

            // Grid lines
            ForEach(gridHours, id: \.self) { hour in
                Rectangle()
                    .fill(DS.Colors.borderSubtle.opacity(0.35))
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
                    accentColor: DS.Colors.borderStrong
                )
                .offset(y: firstTaskOffset)
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
                        // Immediate update - no animation lag
                        taskStore.moveTaskToWeekDay(droppedTask, dayIndex: targetIndex, hour: hour, minute: minute)
                    }
                )
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

// MARK: - Task Pin Position
struct TaskPinPosition: View {
    @Environment(TaskDragState.self) private var dragState
    @State private var isPressed = false
    @GestureState private var dragOffset: CGSize = .zero

    let task: TaskItem
    let hourHeight: CGFloat
    let startHour: Int
    let columnIndex: Int
    let onTap: () -> Void
    var onDrop: ((TaskItem, Int, Int, Int) -> Void)? = nil

    private var isDragging: Bool {
        dragState.isDraggedTask(task)
    }

    private var isRoutineMarker: Bool {
        task.recurrenceOption != nil && task.recurrenceOption != "None"
    }

    var body: some View {
        MiniTaskPin(task: task, hourHeight: hourHeight)
            .scaleEffect(isDragging ? 1.08 : (isPressed ? 1.03 : 1.0))
            .opacity(isDragging ? 0.4 : 1.0)
            .offset(y: yOffset)
            .animation(.easeOut(duration: 0.15), value: isDragging)
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .gesture(isRoutineMarker ? nil : dragGesture)
            .simultaneousGesture(isRoutineMarker ? nil : tapGesture)
            .accessibilityHint(isRoutineMarker ? "Routine marker" : "Hold to drag, tap to preview")
    }

    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if !dragState.isDragging {
                    onTap()
                }
            }
    }

    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.15)
            .onChanged { _ in
                isPressed = true
            }
            .onEnded { _ in
                isPressed = false
                // Start drag mode
                dragState.startDrag(task: task, columnIndex: columnIndex, location: .zero)
            }
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    dragState.updateDrag(location: value.location)
                }
                .onEnded { _ in
                    // Complete the drop
                    if let result = dragState.endDrag() {
                        onDrop?(result.task, result.toIndex, result.toHour, result.toMinute)
                    }
                }
            )
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
            MiniTaskPin(
                task: task,
                hourHeight: hourHeight,
                overrideTime: dragState.formattedTargetTime
            )
            .scaleEffect(1.06)
            .shadowLifted()
            .position(
                x: dragState.dragLocation.x - geo.frame(in: .global).minX,
                y: dragState.dragLocation.y - geo.frame(in: .global).minY
            )
            .transaction { transaction in
                transaction.animation = nil
            }
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
            .foregroundStyle(DS.Colors.textTertiary)
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
                    .foregroundStyle(DS.Colors.textPrimary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.xs)
            .background(DS.Colors.surfacePrimary.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.pill)
                    .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DS.Colors.borderSubtle)
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DS.Colors.accent, DS.Colors.primary],
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
                .foregroundStyle(DS.Colors.textTertiary)
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
