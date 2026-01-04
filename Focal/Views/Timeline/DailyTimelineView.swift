import SwiftUI

struct DailyTimelineView: View {
    @Environment(TaskStore.self) private var taskStore
    @State private var selectedTask: TaskItem?

    private let timelineStartHour = 6
    private let timelineEndHour = 23

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 100)
                    .fill(DS.Colors.divider)
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            
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
                    ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                        TimeSlot(
                            hour: hour,
                            tasks: taskStore.tasksAt(hour: hour, for: taskStore.selectedDate),
                            onTaskTap: { task in
                                selectedTask = task
                            },
                            onToggleComplete: { task in
                                taskStore.toggleCompletion(for: task)
                            }
                        )
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.vertical, DS.Spacing.md)
                .padding(.bottom, 120) // Space for bottom nav
            }
        }
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: -4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environment(taskStore)
        }
    }
}

// MARK: - Time Slot
struct TimeSlot: View {
    let hour: Int
    let tasks: [TaskItem]
    let onTaskTap: (TaskItem) -> Void
    let onToggleComplete: (TaskItem) -> Void

    @State private var isCurrentHour = false

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.md) {
            // Time label
            TimeLabel(hour: hour)

            // Vertical solid line
            Rectangle()
                .fill(DS.Colors.divider)
                .frame(width: 1)
                .frame(minHeight: tasks.isEmpty ? 60 : nil)

            // Tasks or empty state
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                if tasks.isEmpty {
                    EmptyTimeSlot(hour: hour)
                } else {
                    ForEach(tasks) { task in
                        TaskCardView(
                            task: task,
                            onToggleComplete: { onToggleComplete(task) },
                            onTap: { onTaskTap(task) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DS.Spacing.sm)
        .overlay(alignment: .leading) {
            if isCurrentHourSlot {
                CurrentTimeIndicator()
                    .offset(x: 48, y: currentMinuteOffset)
            }
        }
        .onAppear {
            isCurrentHour = Date().hour == hour
        }
    }

    private var isCurrentHourSlot: Bool {
        let now = Date()
        return now.hour == hour && taskStore.selectedDate.isToday
    }

    private var currentMinuteOffset: CGFloat {
        CGFloat(Date().minute) / 60.0 * 60 // Approximate based on slot height
    }

    @Environment(TaskStore.self) private var taskStore
}

// MARK: - Empty Time Slot
struct EmptyTimeSlot: View {
    let hour: Int
    @State private var showAddTask = false
    @Environment(TaskStore.self) private var taskStore

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Text("💤")
                .scaledFont(size: 14, relativeTo: .callout)

            Text("Free time")
                .scaledFont(size: 14, relativeTo: .callout)
                .foregroundStyle(DS.Colors.textSecondary)

            Spacer()

            Button {
                showAddTask = true
            } label: {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    Text("Add")
                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                }
                .foregroundStyle(DS.Colors.sky)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.sky.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DS.Spacing.md)
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet(presetHour: hour)
                .environment(taskStore)
        }
    }
}

#Preview {
    let store = TaskStore()
    store.loadSampleData()

    return DailyTimelineView()
        .environment(store)
        .background(DS.Colors.background)
}
