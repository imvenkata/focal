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
    private let gridStride = 2  // Show grid every 2 hours for cleaner look
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
                        HStack(spacing: DS.Sizes.weekColumnSpacing) {
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

                // Only show hint when dragging
                if dragState.isDragging {
                    Text("Release to schedule")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(DS.Colors.accent)
                        .padding(.top, DS.Spacing.sm)
                        .padding(.bottom, DS.Spacing.md)
                        .transition(.opacity)
                } else {
                    Spacer()
                        .frame(height: DS.Spacing.lg)
                }
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
            // Column background - subtle for today
            if date.isToday {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.primary.opacity(0.06))
            }

            // Subtle column separator line
            Rectangle()
                .fill(DS.Colors.borderSubtle.opacity(0.3))
                .frame(width: 0.5)
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Grid lines - horizontal hour markers
            ForEach(Array(startHour...endHour), id: \.self) { hour in
                let isMajorHour = hour % gridStride == 0
                Rectangle()
                    .fill(DS.Colors.borderSubtle.opacity(isMajorHour ? 0.4 : 0.15))
                    .frame(height: isMajorHour ? 1 : 0.5)
                    .frame(maxWidth: .infinity)
                    .offset(y: CGFloat(hour - startHour) * hourHeight)
            }

            // Drop target highlight
            if isDropTarget {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.accent.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(DS.Colors.accent, lineWidth: 2)
                    )
                    .transition(.opacity)
            }

            // Drop zone preview
            if isDropTarget, dragState.draggedTask != nil, let targetHour = dragState.targetHour {
                let targetMinute = dragState.targetMinute
                let hoursSinceStart = CGFloat(targetHour - startHour) + CGFloat(targetMinute) / 60.0
                let previewYOffset = hoursSinceStart * hourHeight

                Circle()
                    .fill(DS.Colors.accent.opacity(0.3))
                    .frame(width: DS.Sizes.glassIconSize + 8, height: DS.Sizes.glassIconSize + 8)
                    .overlay(
                        Circle()
                            .stroke(DS.Colors.accent, lineWidth: 2)
                    )
                    .offset(y: previewYOffset)
                    .animation(.easeOut(duration: 0.1), value: targetHour)
                    .animation(.easeOut(duration: 0.1), value: targetMinute)
            }

            // Vertical task connector line
            if tasks.count > 1 {
                let sortedTasks = tasks.sorted { $0.startTime < $1.startTime }
                if let firstTask = sortedTasks.first, let lastTask = sortedTasks.last {
                    let firstTaskTime = Double(firstTask.startTime.hour) + Double(firstTask.startTime.minute) / 60.0
                    let firstTaskOffset = CGFloat(firstTaskTime - Double(startHour)) * hourHeight + (DS.Sizes.glassIconSize / 2)

                    let lastTaskTime = Double(lastTask.startTime.hour) + Double(lastTask.startTime.minute) / 60.0
                    let lastTaskOffset = CGFloat(lastTaskTime - Double(startHour)) * hourHeight + (DS.Sizes.glassIconSize / 2)

                    let trackHeight = max(lastTaskOffset - firstTaskOffset, 0)

                    if trackHeight > 0 {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(DS.Colors.borderStrong.opacity(0.3))
                            .frame(width: 2, height: trackHeight)
                            .offset(y: firstTaskOffset)
                    }
                }
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
        .animation(.easeOut(duration: 0.15), value: isDropTarget)
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
        Text(formattedHour)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(DS.Colors.textTertiary)
            .frame(width: DS.Sizes.timeLabelWidth, alignment: .trailing)
    }

    private var formattedHour: String {
        if hour == 0 || hour == 12 {
            return hour == 0 ? "12a" : "12p"
        } else if hour < 12 {
            return "\(hour)a"
        } else {
            return "\(hour - 12)p"
        }
    }
}

// MARK: - Weekly Mini Stats
private struct WeeklyMiniStatsBar: View {
    let energy: Int
    let completed: Int
    let total: Int
    let progress: Double

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Energy indicator
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DS.Colors.amber)
                Text("\(energy)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Colors.textPrimary)
            }

            // Progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DS.Colors.borderSubtle.opacity(0.5))
                        .frame(height: 4)

                    Capsule()
                        .fill(DS.Colors.accent)
                        .frame(width: max(4, proxy.size.width * progress), height: 4)
                }
            }
            .frame(height: 4)

            // Completion count
            Text("\(completed)/\(total)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
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
