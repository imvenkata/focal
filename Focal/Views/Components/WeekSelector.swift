import SwiftUI

struct WeekSelector: View {
    @Binding var selectedDate: Date
    let viewMode: TaskStore.ViewMode
    let weekDates: [Date]
    let tasksForWeek: [[TaskItem]]
    let onDateSelected: (Date) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
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
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
        }
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
            VStack(spacing: 4) {
                // Weekday label
                Text(date.shortWeekdayName.uppercased())
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.stone400)
                    .tracking(1)

                // Day number with circle
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 36, height: 36)
                        .shadow(color: isSelected ? DS.Colors.stone800.opacity(0.25) : Color.clear, radius: 8, y: 2)

                    Text("\(date.dayNumber)")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(textColor)
                }

                // Task indicator dots
                HStack(spacing: 2) {
                    ForEach(Array(tasksForDay.prefix(3).enumerated()), id: \.offset) { index, task in
                        Circle()
                            .fill(task.color.color)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(height: 8)
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
            return DS.Colors.stone800
        } else if date.isToday {
            return DS.Colors.amber100
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if date.isToday {
            return DS.Colors.amber600
        } else {
            return DS.Colors.stone700
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
    .background(DS.Colors.background)
}
