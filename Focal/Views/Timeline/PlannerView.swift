import SwiftUI

struct PlannerView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var previewTask: TaskItem?

    var body: some View {
        @Bindable var store = taskStore

        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                PlannerHeader(
                    selectedDate: store.selectedDate,
                    viewMode: store.viewMode,
                    onToggleViewMode: { store.toggleViewMode() },
                    onPreviousWeek: {
                        if store.viewMode == .week {
                            store.goToPreviousWeek()
                        } else {
                            store.goToPreviousDay()
                        }
                    },
                    onNextWeek: {
                        if store.viewMode == .week {
                            store.goToNextWeek()
                        } else {
                            store.goToNextDay()
                        }
                    }
                )

                // Week selector
                WeekSelector(
                    selectedDate: $store.selectedDate,
                    viewMode: store.viewMode,
                    weekDates: store.weekDates,
                    tasksForWeek: store.tasksForWeek,
                    onDateSelected: { date in
                        store.selectDate(date)
                        if store.viewMode == .week {
                            store.viewMode = .day
                        }
                    }
                )
                .environment(taskStore)

                Divider()

                // Timeline content
                Group {
                    switch store.viewMode {
                    case .week:
                        WeeklyTimelineView(onTaskTap: { task in
                            handlePreview(for: task)
                        })
                    case .day:
                        DailyTimelineView(onClose: {
                            handleCloseDayView()
                        })
                    }
                }
                .animation(DS.Animation.spring, value: store.viewMode)
            }

            if store.viewMode == .week, let previewTask {
                TaskPreviewSheet(
                    task: previewTask,
                    onExpand: {
                        handleExpandDayView()
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            self.previewTask = nil
                        }
                    }
                )
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Sizes.bottomNavHeight + DS.Spacing.lg)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
                .zIndex(1)
            }
        }
        .background(DS.Colors.bgPrimary)
    }

    private func handlePreview(for task: TaskItem) {
        taskStore.selectDate(task.startTime)
        withAnimation(DS.Animation.spring) {
            // Toggle: if tapping the same task, hide preview; otherwise show new task
            if previewTask?.id == task.id {
                previewTask = nil
            } else {
                previewTask = task
            }
        }
    }

    private func handleExpandDayView() {
        taskStore.setViewMode(.day)
    }

    private func handleCloseDayView() {
        taskStore.setViewMode(.week)
    }
}

// MARK: - Planner Header
struct PlannerHeader: View {
    let selectedDate: Date
    let viewMode: TaskStore.ViewMode
    let onToggleViewMode: () -> Void
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void

    var body: some View {
        HStack {
            // Month/Year with navigation
            HStack(spacing: DS.Spacing.sm) {
                Button(action: onPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textTertiary)
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)

                HStack(spacing: 4) {
                    Text(headerTitle)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    Text(String(selectedDate.yearNumber))
                        .scaledFont(size: 16, weight: .light, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.warning.opacity(0.85))
                }

                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textTertiary)
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
            }

            Spacer()

            // View mode toggle
            ViewModeToggle(viewMode: viewMode, onToggle: onToggleViewMode)
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.md)
    }
    
    private var headerTitle: String {
        if viewMode == .day {
            return "\(selectedDate.dayNumber) \(selectedDate.monthName)"
        } else {
            return selectedDate.monthName
        }
    }
}

// MARK: - View Mode Toggle
struct ViewModeToggle: View {
    let viewMode: TaskStore.ViewMode
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DS.Spacing.xs) {
                Text(viewMode == .week ? "Week" : "Day")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textPrimary)

                Image(systemName: "arrow.left.arrow.right")
                    .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textTertiary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View mode")
        .accessibilityValue(viewMode == .week ? "Week" : "Day")
        .accessibilityHint("Double tap to switch view")
    }
}

// MARK: - Task Preview Sheet
private struct TaskPreviewSheet: View {
    let task: TaskItem
    let onExpand: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let expandThreshold: CGFloat = -50
    private let dismissThreshold: CGFloat = 80

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            // Drag handle
            RoundedRectangle(cornerRadius: DS.Radius.pill)
                .fill(DS.Colors.borderStrong.opacity(0.5))
                .frame(width: DS.Sizes.sheetHandle, height: 5)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.xs)

            HStack(spacing: DS.Spacing.lg) {
                TaskPreviewIcon(task: task)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(timeDetail)
                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)

                    Text(task.title)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textPrimary)
                }

                Spacer()

                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.clear : task.color.color, lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(DS.Colors.success)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .scaledFont(size: 11, weight: .bold, relativeTo: .caption)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
        }
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        .shadowLifted()
        .scaleEffect(scaleEffect)
        .offset(y: currentOffset)
        .opacity(opacity)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    isDragging = true
                    // Rubber band effect: resistance when dragging up
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height * 0.4
                    } else {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = value.predictedEndTranslation.height - value.translation.height

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        if value.translation.height < expandThreshold || velocity < -200 {
                            // Swipe up - expand to day view
                            onExpand()
                        } else if value.translation.height > dismissThreshold || velocity > 200 {
                            // Swipe down - dismiss
                            onDismiss()
                        }
                        dragOffset = 0
                    }
                }
        )
        .onTapGesture {
            onExpand()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(timeDetail)")
        .accessibilityHint("Swipe up to expand, swipe down to dismiss, or tap to view")
    }

    private var currentOffset: CGFloat {
        dragOffset
    }

    private var scaleEffect: CGFloat {
        if dragOffset < 0 {
            // Slightly scale up when dragging up
            return 1 + (abs(dragOffset) / 500)
        } else {
            // Scale down when dragging down
            return max(0.9, 1 - (dragOffset / 400))
        }
    }

    private var opacity: CGFloat {
        if dragOffset > 0 {
            return max(0.3, 1 - (dragOffset / 200))
        }
        return 1
    }

    private var timeDetail: String {
        "\(task.timeRangeFormatted) (\(task.durationFormatted))"
    }
}

private struct TaskPreviewIcon: View {
    let task: TaskItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(task.color.color)

            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(
                    LinearGradient(
                        colors: [
                            DS.Colors.textInverse.opacity(0.25),
                            Color.clear,
                            Color.black.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(task.color.color.saturated(by: 1.2), lineWidth: 1.5)

            Text(task.icon)
                .scaledFont(size: 18, relativeTo: .title3)
        }
        .frame(width: 44, height: 44)
        .shadowColored(task.color.color)
        .opacity(task.isCompleted ? 0.65 : 1)
    }
}

#Preview {
    PlannerView()
        .environment(TaskStore())
        .environment(TaskDragState())
}
