import SwiftUI

struct DailyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var selectedTask: TaskItem?
    @State private var showAddTask = false
    var onClose: (() -> Void)?

    private let timelineStartHour = 6
    private let timelineEndHour = 23
    private let minuteHeight: CGFloat = 1

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
                        TimelineSegmentRow(
                            timeLabel: segment.showsTimeLabel ? segment.startTime : nil,
                            minHeight: segmentMinHeight(for: segment)
                        ) {
                            switch segment {
                            case .task(let task):
                                TaskCardView(
                                    task: task,
                                    onToggleComplete: { taskStore.toggleCompletion(for: task) },
                                    onTap: { selectedTask = task },
                                    onDelete: { taskStore.deleteTask(task) }
                                )
                            case .gap(_, _, let duration):
                                EmptyIntervalView(gap: duration)
                                    .padding(.leading, DS.Sizes.taskPillDefault + DS.Spacing.md)
                            }
                        }
                    }

                    TimelineSegmentRow(
                        timeLabel: nil,
                        minHeight: DS.Sizes.minTouchTarget
                    ) {
                        AddTaskRow {
                            showAddTask = true
                        }
                        .padding(.leading, DS.Sizes.taskPillDefault + DS.Spacing.md)
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.vertical, DS.Spacing.md)
                .padding(.bottom, 120) // Space for bottom nav
                .overlay(alignment: .leading) {
                    TimelineGuideLine()
                        .stroke(DS.Colors.stone200, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, DS.Sizes.timeLabelWidth + DS.Spacing.xs)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .topLeading) {
                    if shouldShowCurrentTimeIndicator {
                        CurrentTimeIndicator()
                            .padding(.leading, DS.Sizes.timeLabelWidth + DS.Spacing.xs)
                            .offset(y: currentTimeOffset + DS.Spacing.md)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: -4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
                .environment(taskStore)
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
        DS.Sizes.taskPillDefault + DS.Spacing.lg
    }

    private var minimumGapHeight: CGFloat {
        DS.Sizes.minTouchTarget
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

    private var handleBar: some View {
        Group {
            if let onClose {
                Button(action: onClose) {
                    handleCapsule
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close day view")
                .accessibilityHint("Returns to the week overview")
            } else {
                handleCapsule
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var handleCapsule: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 100)
                .fill(DS.Colors.divider)
                .frame(width: 40, height: 4)
            Spacer()
        }
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
            return false
        }
    }
}

// MARK: - Timeline Segment Row
private struct TimelineSegmentRow<Content: View>: View {
    let timeLabel: Date?
    let minHeight: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.sm) {
            TimelineTimeLabel(time: timeLabel)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: minHeight, alignment: .top)
    }
}

// MARK: - Timeline Time Label
private struct TimelineTimeLabel: View {
    let time: Date?

    var body: some View {
        Group {
            if let time {
                Text(time.formattedTime)
                    .scaledFont(size: 10, weight: .medium, design: .monospaced, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.stone400)
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

// MARK: - Add Task Row
private struct AddTaskRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.amber)
                        .frame(width: 24, height: 24)

                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(.white)
                }

                Text("Add Task")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.amber)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.stone50)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add task")
        .accessibilityHint("Opens the new task sheet")
    }
}

#Preview {
    let store = TaskStore()
    store.loadSampleData()

    return DailyTimelineView()
        .environment(store)
        .background(DS.Colors.background)
}
