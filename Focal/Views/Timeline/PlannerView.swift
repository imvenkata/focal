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
                    onPreviousWeek: { store.goToPreviousWeek() },
                    onNextWeek: { store.goToNextWeek() }
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
                TaskPreviewSheet(task: previewTask, onExpand: {
                    handleExpandDayView()
                })
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Sizes.bottomNavHeight + DS.Spacing.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .background(DS.Colors.background)
        .onAppear {
            if store.tasks.isEmpty {
                store.loadSampleData()
            }
        }
    }

    private func handlePreview(for task: TaskItem) {
        taskStore.selectDate(task.startTime)
        withAnimation(DS.Animation.spring) {
            previewTask = task
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
                        .foregroundStyle(DS.Colors.stone400)
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)

                HStack(spacing: 4) {
                    Text(headerTitle)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.stone800)
                    
                    Text(String(selectedDate.yearNumber))
                        .scaledFont(size: 16, weight: .light, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.amber.opacity(0.8))
                }

                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.stone400)
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
                    .foregroundStyle(DS.Colors.stone400)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.stone100)
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

    @GestureState private var dragOffset: CGFloat = 0

    private let dragThreshold: CGFloat = 60

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            Button(action: onExpand) {
                RoundedRectangle(cornerRadius: DS.Radius.pill)
                    .fill(DS.Colors.divider)
                    .frame(width: DS.Sizes.sheetHandle, height: 4)
                    .padding(.top, DS.Spacing.sm)
                    .padding(.bottom, DS.Spacing.xs)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Expand day view")
            .accessibilityHint("Shows the full day timeline")

            HStack(spacing: DS.Spacing.lg) {
                TaskPreviewIcon(task: task)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(timeDetail)
                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.stone500)

                    Text(task.title)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(DS.Colors.stone800)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.clear : task.color.color, lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(DS.Colors.emerald500)
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
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 20, y: 6)
        .offset(y: dragOffset < 0 ? dragOffset * 0.15 : 0)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 12)
                .updating($dragOffset) { value, state, _ in
                    if value.translation.height < 0 {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -dragThreshold {
                        onExpand()
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(timeDetail)")
        .accessibilityHint("Swipe up to expand the day view")
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
                            Color.white.opacity(0.25),
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
        .shadow(color: task.color.color.opacity(0.35), radius: 6, y: 3)
        .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
        .opacity(task.isCompleted ? 0.65 : 1)
    }
}

#Preview {
    PlannerView()
        .environment(TaskStore())
}
