import SwiftUI

struct PlannerView: View {
    @Environment(TaskStore.self) private var taskStore

    var body: some View {
        @Bindable var store = taskStore

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
                    WeeklyTimelineView()
                case .day:
                    DailyTimelineView()
                }
            }
            .animation(DS.Animation.spring, value: store.viewMode)
        }
        .background(DS.Colors.background)
        .onAppear {
            if store.tasks.isEmpty {
                store.loadSampleData()
            }
        }
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
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)

                HStack(spacing: 4) {
                    Text(headerTitle)
                        .font(DS.Typography.title2())
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    Text(String(selectedDate.yearNumber))
                        .font(DS.Typography.title2(weight: .light))
                        .foregroundStyle(DS.Colors.amber.opacity(0.8))
                }

                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textSecondary)
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
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: iconName)
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)

                Text(currentLabel)
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)

                Image(systemName: "arrow.left.arrow.right")
                    .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .foregroundStyle(DS.Colors.textPrimary)
            .padding(.horizontal, DS.Spacing.md)
            .frame(height: DS.Sizes.minTouchTarget)
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.divider, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(currentLabel) view")
        .accessibilityHint("Double tap to switch to \(nextLabel) view")
    }

    private var currentLabel: String {
        viewMode == .week ? "Week" : "Day"
    }

    private var nextLabel: String {
        viewMode == .week ? "Day" : "Week"
    }

    private var iconName: String {
        viewMode == .week ? "rectangle.grid.2x2" : "list.bullet.rectangle"
    }
}

#Preview {
    PlannerView()
        .environment(TaskStore())
}
