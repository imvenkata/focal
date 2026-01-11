import SwiftUI

struct WeekSelector: View {
    @Binding var selectedDate: Date
    let viewMode: TaskStore.ViewMode
    let weekDates: [Date]
    let tasksForWeek: [[TaskItem]]
    let onDateSelected: (Date) -> Void

    // Layout constants matching WeeklyTimelineView
    private var timeLabelsWidth: CGFloat {
        DS.Sizes.timeLabelWidth + DS.Spacing.sm // 32 + 8 = 40pt
    }

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let horizontalPadding = DS.Spacing.md * 2 // 12 * 2 = 24pt (matches WeeklyTimelineView)
            let availableWidth = totalWidth - horizontalPadding
            let columnsWidth = availableWidth - timeLabelsWidth
            let totalSpacing = DS.Sizes.weekColumnSpacing * 6 // 6pt * 6 gaps = 36pt
            let columnWidth = (columnsWidth - totalSpacing) / 7

            HStack(spacing: 0) {
                // Spacer matching time labels width
                if viewMode == .week {
                    Spacer()
                        .frame(width: timeLabelsWidth)
                }

                HStack(spacing: viewMode == .week ? DS.Sizes.weekColumnSpacing : DS.Spacing.xs * 0.75) {
                    ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                        DayCircle(
                            date: date,
                            isSelected: date.isSameDay(as: selectedDate),
                            viewMode: viewMode,
                            taskCount: tasksForWeek[index].count,
                            hasCompletedTasks: tasksForWeek[index].contains { $0.isCompleted }
                        ) {
                            onDateSelected(date)
                        }
                        .frame(width: viewMode == .week ? columnWidth : nil)
                    }
                }

                if viewMode != .week {
                    Spacer()
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
        .frame(height: 70) // Fixed height for day circles
    }
}

// MARK: - Day Circle
struct DayCircle: View {
    let date: Date
    let isSelected: Bool
    let viewMode: TaskStore.ViewMode
    let taskCount: Int
    let hasCompletedTasks: Bool
    let action: () -> Void
    
    @Environment(TaskStore.self) private var taskStore

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs * 0.75) {
                // Weekday label
                Text(date.shortWeekdayName.uppercased())
                    .scaledFont(size: 9, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textTertiary)

                // Day number with circle
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 28, height: 28)
                        .shadow(color: isSelected ? DS.Colors.primary.opacity(0.25) : Color.clear, radius: 8, y: 2)

                    Text("\(date.dayNumber)")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(textColor)
                }

                // Task indicator dots
                HStack(spacing: DS.Spacing.xs * 0.5) {
                    ForEach(Array(tasksForDay.prefix(3).enumerated()), id: \.offset) { index, task in
                        Circle()
                            .fill(task.color.color)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .frame(width: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
        .opacity(isDimmed ? 0.4 : 1)
        .scaleEffect(isDimmed ? 0.9 : 1)
        .animation(DS.Animation.gentle, value: isDimmed)
        .accessibilityLabel("\(date.formattedDate), \(taskCount) tasks")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var circleColor: Color {
        if isSelected {
            return DS.Colors.primary
        } else if date.isToday {
            return DS.Colors.warningLight
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if date.isToday {
            return DS.Colors.warning
        } else {
            return DS.Colors.textPrimary
        }
    }

    private var isDimmed: Bool {
        viewMode == .day && !isSelected
    }
    
    private var tasksForDay: [TaskItem] {
        // Find tasks for this specific date from taskStore
        guard let index = taskStore.weekDates.firstIndex(where: { $0.isSameDay(as: date) }) else {
            return []
        }
        return taskStore.tasksForWeek[index]
    }
}

#Preview {
    WeekSelector(
        selectedDate: .constant(Date()),
        viewMode: .week,
        weekDates: Date.weekDates,
        tasksForWeek: [[],[],[],[],[],[],[]],
        onDateSelected: { _ in }
    )
    .padding()
    .background(DS.Colors.bgPrimary)
}
