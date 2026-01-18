import SwiftUI

struct DailyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var selectedTask: TaskItem?
    @State private var showAddTask = false
    @State private var presetHour: Int?
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var horizontalSwipeOffset: CGFloat = 0
    @State private var swipeDirection: SwipeDirection = .none
    var onClose: (() -> Void)?

    private enum SwipeDirection {
        case none, left, right
    }

    // Pinch-to-zoom state
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var showZoomIndicator = false
    @AppStorage("timelineZoomLevel") private var savedZoomLevel: Double = 1.0

    private let timelineStartHour = 6
    private let timelineEndHour = 23  // Aligned with weekly view (was 22)
    private let dismissThreshold: CGFloat = 120
    private let swipeThreshold: CGFloat = 50
    private let baseMinuteHeight: CGFloat = 0.5

    // Zoom constraints
    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 2.0

    private var minuteHeight: CGFloat {
        baseMinuteHeight * zoomScale
    }

    private var timelineVerticalPadding: CGFloat { DS.Spacing.md }
    private var timelineBottomPadding: CGFloat { DS.Sizes.bottomNavHeight + DS.Spacing.md }
    private var timelineLineOffset: CGFloat {
        // Offset line further right to avoid overlapping time labels
        DS.Sizes.timeLabelWidth + DS.Spacing.md + DS.Spacing.xs
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            handleBar
            
            // Stats bar
            StatsBar(
                energy: taskStore.totalEnergyForSelectedDate,
                taskCount: taskStore.tasksForSelectedDate.count,
                completedCount: taskStore.completedTasksForSelectedDate.count
            )
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.md)
            
            // Timeline content
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(timelineSegments) { segment in
                        let rowHeight = segmentMinHeight(for: segment)
                        TimelineSegmentRow(
                            startTime: segment.showsTimeLabel ? segment.startTime : nil,
                            endTime: segment.showsEndTimeLabel ? segment.endTime : nil,
                            minHeight: rowHeight,
                            showEndTime: segment.showsEndTimeLabel
                        ) {
                            switch segment {
                            case .task(let task):
                                TaskCardView(
                                    task: task,
                                    onToggleComplete: { taskStore.toggleCompletion(for: task) },
                                    onTap: { selectedTask = task },
                                    onLongPress: { HapticManager.shared.dragActivated() },
                                    pillHeight: rowHeight,
                                    onDelete: { taskStore.deleteTask(task) },
                                    onReschedule: { hours in
                                        taskStore.rescheduleTask(task, byAddingHours: hours)
                                    },
                                    onRescheduleTomorrow: {
                                        taskStore.rescheduleTaskToTomorrow(task)
                                    }
                                )
                            case .gap:
                                EmptyIntervalView(
                                    gap: segment.duration,
                                    startTime: segment.startTime,
                                    endTime: segment.endTime,
                                    minHeight: rowHeight,
                                    showsAddButton: false,
                                    onAddTask: { showAddTask = true },
                                    onTapToCreate: { time in
                                        presetHour = Calendar.current.component(.hour, from: time)
                                        showAddTask = true
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.vertical, timelineVerticalPadding)
                .padding(.bottom, timelineBottomPadding) // Space for bottom nav
                .overlay(alignment: .leading) {
                    TimelineGuideLine()
                        .stroke(DS.Colors.borderSubtle.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, timelineLineOffset)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .topLeading) {
                    if shouldShowCurrentTimeIndicator {
                        CurrentTimeIndicator()
                            .padding(.leading, timelineLineOffset)
                            .offset(y: currentTimeOffset + timelineVerticalPadding)
                            .allowsHitTesting(false)
                    }
                }
            }
            .refreshable {
                await MainActor.run {
                    HapticManager.shared.selection()
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = lastZoomScale * value
                        zoomScale = min(max(newScale, minZoom), maxZoom)
                        showZoomIndicator = true
                    }
                    .onEnded { value in
                        lastZoomScale = zoomScale
                        savedZoomLevel = Double(zoomScale)
                        HapticManager.shared.selection()
                        // Hide indicator after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                showZoomIndicator = false
                            }
                        }
                    }
            )
            .onTapGesture(count: 2) {
                // Double-tap to reset zoom
                withAnimation(DS.Animation.spring) {
                    zoomScale = 1.0
                    lastZoomScale = 1.0
                    savedZoomLevel = 1.0
                }
                HapticManager.shared.selection()
            }
            .overlay(alignment: .topTrailing) {
                // Zoom level indicator
                if showZoomIndicator {
                    ZoomIndicator(scale: zoomScale)
                        .padding(.trailing, DS.Spacing.xl)
                        .padding(.top, DS.Spacing.lg)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .onAppear {
                // Restore saved zoom level
                zoomScale = CGFloat(savedZoomLevel)
                lastZoomScale = zoomScale
            }
        }
        .offset(x: horizontalSwipeOffset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onChanged { value in
                    // Only track horizontal movement if it's primarily horizontal
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    if abs(horizontal) > abs(vertical) && abs(vertical) < 30 {
                        horizontalSwipeOffset = horizontal * 0.3
                    }
                }
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let velocity = value.velocity.width
                    
                    // Only trigger if horizontal movement exceeds vertical
                    if abs(horizontal) > abs(vertical) {
                        if horizontal < -swipeThreshold || velocity < -500 {
                            // Swipe left → next day
                            swipeDirection = .left
                            withAnimation(.easeOut(duration: 0.15)) {
                                horizontalSwipeOffset = -50
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                taskStore.goToNextDay()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    horizontalSwipeOffset = 0
                                }
                            }
                        } else if horizontal > swipeThreshold || velocity > 500 {
                            // Swipe right → previous day
                            swipeDirection = .right
                            withAnimation(.easeOut(duration: 0.15)) {
                                horizontalSwipeOffset = 50
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                taskStore.goToPreviousDay()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    horizontalSwipeOffset = 0
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                horizontalSwipeOffset = 0
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            horizontalSwipeOffset = 0
                        }
                    }
                }
        )
        .overlay(alignment: .bottomTrailing) {
            CompactFABButton {
                showAddTask = true
            }
            .padding(.trailing, DS.Spacing.md)
            .padding(.bottom, DS.Sizes.bottomNavHeight + DS.Spacing.sm)
        }
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous))
        .shadow(color: DS.Colors.overlay.opacity(0.08), radius: 24, y: -4)
        .offset(y: max(0, dragOffset))
        .scaleEffect(dragScaleEffect, anchor: .bottom)
        .opacity(dragOpacity)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    // Only allow downward drag
                    if value.translation.height > 0 {
                        isDragging = true
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = value.predictedEndTranslation.height - value.translation.height

                    if value.translation.height > dismissThreshold || velocity > 300 {
                        // Dismiss with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = UIScreen.main.bounds.height
                        }
                        // Call onClose after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onClose?()
                        }
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(isPresented: $showAddTask) {
            PlannerTaskCreationSheet(presetHour: presetHour)
                .environment(taskStore)
        }
        .onChange(of: showAddTask) { _, isShowing in
            // Reset preset hour when sheet is dismissed
            if !isShowing {
                presetHour = nil
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environment(taskStore)
        }
    }

    private var timelineStart: Date {
        taskStore.selectedDate.withTime(hour: timelineStartHour)
    }

    private var timelineEnd: Date {
        taskStore.selectedDate.withTime(hour: timelineEndHour)
    }

    private var minimumTaskHeight: CGFloat {
        DS.Sizes.taskPillDefault
    }

    private var minimumGapHeight: CGFloat {
        DS.Spacing.xl
    }

    private var timelineSegments: [TimelineSegment] {
        let tasks = taskStore.tasksForSelectedDate
        let timelineStart = timelineStart
        let timelineEnd = timelineEnd

        var segments: [TimelineSegment] = []
        var cursor = timelineStart

        for task in tasks {
            let taskStart = max(task.startTime, timelineStart)
            let taskEnd = min(task.endTime, timelineEnd)

            guard taskEnd > timelineStart, taskStart < timelineEnd else {
                continue
            }

            if taskStart > cursor {
                let gap = taskStart.timeIntervalSince(cursor)
                segments.append(.gap(id: UUID(), start: cursor, duration: gap))
            }

            segments.append(.task(task))
            cursor = max(cursor, task.endTime)
        }

        if cursor < timelineEnd {
            let gap = timelineEnd.timeIntervalSince(cursor)
            segments.append(.gap(id: UUID(), start: cursor, duration: gap))
        }

        if segments.isEmpty {
            let gap = timelineEnd.timeIntervalSince(timelineStart)
            segments.append(.gap(id: UUID(), start: timelineStart, duration: gap))
        }

        return segments
    }

    private func segmentMinHeight(for segment: TimelineSegment) -> CGFloat {
        let durationMinutes = max(0, segment.duration / 60)
        let scaledHeight = CGFloat(durationMinutes) * minuteHeight

        switch segment {
        case .task:
            return max(minimumTaskHeight, scaledHeight)
        case .gap:
            return max(minimumGapHeight, scaledHeight)
        }
    }

    private var dragScaleEffect: CGFloat {
        let progress = min(dragOffset / 300, 1)
        return 1 - (progress * 0.05)
    }

    private var dragOpacity: CGFloat {
        let progress = min(dragOffset / 400, 1)
        return 1 - (progress * 0.3)
    }

    private var handleBar: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: DS.Radius.pill)
                .fill(DS.Colors.borderStrong.opacity(isDragging ? 0.7 : 0.4))
                .frame(width: isDragging ? 50 : DS.Sizes.sheetHandle, height: 5)
                .animation(.easeOut(duration: 0.15), value: isDragging)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityLabel("Drag down to close")
        .accessibilityHint("Swipe down to return to week view")
    }

    private var shouldShowCurrentTimeIndicator: Bool {
        let now = Date()
        let hour = now.hour
        return hour >= timelineStartHour && hour < timelineEndHour && taskStore.selectedDate.isToday
    }

    private var currentTimeOffset: CGFloat {
        let now = Date()
        let minutesSinceStart = Double(now.hour - timelineStartHour) * 60 + Double(now.minute)
        return max(0, CGFloat(minutesSinceStart)) * minuteHeight
    }
}

// MARK: - Timeline Segment
private enum TimelineSegment: Identifiable {
    case task(TaskItem)
    case gap(id: UUID, start: Date, duration: TimeInterval)

    var id: UUID {
        switch self {
        case .task(let task):
            return task.id
        case .gap(let id, _, _):
            return id
        }
    }

    var startTime: Date {
        switch self {
        case .task(let task):
            return task.startTime
        case .gap(_, let start, _):
            return start
        }
    }

    var duration: TimeInterval {
        switch self {
        case .task(let task):
            return task.duration
        case .gap(_, _, let duration):
            return duration
        }
    }

    var showsTimeLabel: Bool {
        switch self {
        case .task:
            return true
        case .gap:
            return true
        }
    }

    var showsEndTimeLabel: Bool {
        switch self {
        case .task:
            return true
        case .gap:
            return false
        }
    }

    var endTime: Date {
        switch self {
        case .task(let task):
            return task.endTime
        case .gap(_, let start, let duration):
            return start.addingTimeInterval(duration)
        }
    }
}

// MARK: - Timeline Segment Row
private struct TimelineSegmentRow<Content: View>: View {
    let startTime: Date?
    let endTime: Date?
    let minHeight: CGFloat
    let showEndTime: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: DS.Spacing.sm) {
                TimelineTimeLabel(time: startTime)
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: minHeight, alignment: .top)
            .overlay(alignment: .bottomLeading) {
                if showEndTime, let endTime {
                    TimelineTimeLabel(time: endTime, color: DS.Colors.textTertiary)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Timeline Time Label
private struct TimelineTimeLabel: View {
    let time: Date?
    var color: Color = DS.Colors.textTertiary

    var body: some View {
        Group {
            if let time {
                Text(time.formattedTime)
                    .scaledFont(size: 11, weight: .medium, design: .monospaced, relativeTo: .caption)
                    .foregroundStyle(color)
            } else {
                Color.clear
            }
        }
        .frame(width: DS.Sizes.timeLabelWidth, alignment: .trailing)
    }
}

// MARK: - Timeline Guide Line
private struct TimelineGuideLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

// MARK: - Zoom Indicator
private struct ZoomIndicator: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: zoomIcon)
                .font(.system(size: 14, weight: .semibold))

            Text(zoomText)
                .scaledFont(size: 14, weight: .semibold, design: .monospaced, relativeTo: .callout)
        }
        .foregroundStyle(DS.Colors.textPrimary)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .shadowElevated()
        .accessibilityLabel("Zoom level \(zoomText)")
    }

    private var zoomText: String {
        let percentage = Int(scale * 100)
        return "\(percentage)%"
    }

    private var zoomIcon: String {
        if scale > 1.0 {
            return "plus.magnifyingglass"
        } else if scale < 1.0 {
            return "minus.magnifyingglass"
        } else {
            return "magnifyingglass"
        }
    }
}

#Preview {
    let store = TaskStore()
    store.loadSampleData()

    return DailyTimelineView()
        .environment(store)
        .background(DS.Colors.bgPrimary)
}
