import SwiftUI

struct WeekSelector: View {
    @Binding var selectedDate: Date
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
    let taskCount: Int
    let hasCompletedTasks: Bool
    let action: () -> Void
    
    @Environment(TaskStore.self) private var taskStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Weekday label
                Text(date.shortWeekdayName.uppercased())
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .tracking(1)

                // Day number with circle
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 36, height: 36)
                        .shadow(color: isSelected ? Color.black.opacity(0.25) : Color.clear, radius: 8, y: 2)

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
        .accessibilityLabel("\(date.formattedDate), \(taskCount) tasks")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var circleColor: Color {
        if isSelected {
            return colorScheme == .dark ? DS.Colors.cardBackground : Color(hex: "#292524") // stone-800
        } else if date.isToday {
            return colorScheme == .dark ? DS.Colors.amber.opacity(0.2) : Color(hex: "#FEF3C7") // amber-100
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return colorScheme == .dark ? DS.Colors.textPrimary : .white
        } else if date.isToday {
            return colorScheme == .dark ? DS.Colors.amber : Color(hex: "#B45309") // amber-700
        } else {
            return DS.Colors.textPrimary
        }
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
        weekDates: Date.weekDates,
        tasksForWeek: [[],[],[],[],[],[],[]],
        onDateSelected: { _ in }
    )
    .padding()
    .background(DS.Colors.background)
}
