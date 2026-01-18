import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    let onLongPress: (() -> Void)?
    let onDelete: (() -> Void)?
    let onReschedule: ((Int) -> Void)?
    let onRescheduleTomorrow: (() -> Void)?
    let pillHeight: CGFloat?

    init(
        task: TaskItem,
        onToggleComplete: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onLongPress: (() -> Void)? = nil,
        pillHeight: CGFloat? = nil,
        onDelete: (() -> Void)? = nil,
        onReschedule: ((Int) -> Void)? = nil,
        onRescheduleTomorrow: (() -> Void)? = nil
    ) {
        self.task = task
        self.onToggleComplete = onToggleComplete
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.onDelete = onDelete
        self.onReschedule = onReschedule
        self.onRescheduleTomorrow = onRescheduleTomorrow
        self.pillHeight = pillHeight
    }

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.lg) {
            Button {
                onTap()
            } label: {
                HStack(alignment: .top, spacing: DS.Spacing.lg) {
                    // Task pill - scaled by duration
                    DayViewTaskPill(task: task, height: pillHeight)
                    
                    // Content
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        // Time and duration
                        HStack(spacing: DS.Spacing.sm) {
                            Text(task.timeRangeFormatted)
                                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                                .foregroundStyle(secondaryTextColor)

                            if task.duration > 1800 {
                                Text("(\(task.durationFormatted))")
                                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                                    .foregroundStyle(secondaryTextColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(DS.Colors.borderSubtle.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }

                        // Title
                        Text(task.title)
                            .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                            .foregroundStyle(titleColor)
                            .strikethrough(task.isCompleted, color: secondaryTextColor)

                        // Subtasks or Notes
                        if !task.subtasks.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(task.subtasks.prefix(3)) { subtask in
                                    HStack(spacing: 6) {
                                        Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .scaledFont(size: 10, relativeTo: .caption2)
                                            .foregroundStyle(subtask.isCompleted ? DS.Colors.success : DS.Colors.textTertiary)

                                        Text(subtask.title)
                                            .scaledFont(size: 12, weight: .regular, relativeTo: .caption)
                                            .foregroundStyle(DS.Colors.textSecondary)
                                            .strikethrough(subtask.isCompleted, color: DS.Colors.textTertiary)
                                            .lineLimit(1)
                                    }
                                }

                                if task.subtasks.count > 3 {
                                    Text("+\(task.subtasks.count - 3) more")
                                        .scaledFont(size: 11, weight: .medium, relativeTo: .caption2)
                                        .foregroundStyle(DS.Colors.textTertiary)
                                        .padding(.leading, 16)
                                }
                            }
                            .padding(.top, 4)
                        } else if let notes = task.notes, !notes.isEmpty {
                            Text(notes)
                                .scaledFont(size: 12, weight: .regular, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .lineLimit(2)
                                .padding(.top, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.25)  // Aligned with weekly view for consistency
                    .onEnded { _ in
                        onLongPress?()
                    }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(task.title), \(task.timeRangeFormatted), \(task.isCompleted ? "completed" : "pending")")
            .accessibilityHint("Double tap to view details")

            // Checkbox
            Button {
                onToggleComplete()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.clear : task.color.color, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if task.isCompleted {
                        Circle()
                            .fill(DS.Colors.success)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .scaledFont(size: 12, weight: .bold, relativeTo: .caption)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")
        }
        .padding(.horizontal, DS.Spacing.sm)
        .background(task.isActive ? task.color.lightColor.opacity(0.5) : Color.clear)
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay {
            if task.isActive {
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(task.color.color, lineWidth: 1.5)
            }
        }
        .opacity(rowOpacity)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onToggleComplete()
            } label: {
                Label(task.isCompleted ? "Undo" : "Done", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark")
            }
            .tint(task.isCompleted ? DS.Colors.textSecondary : DS.Colors.success)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .contextMenu {
            // Quick reschedule options
            Menu {
                Button {
                    onReschedule?(1)
                } label: {
                    Label("In 1 hour", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    onReschedule?(2)
                } label: {
                    Label("In 2 hours", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    onRescheduleTomorrow?()
                } label: {
                    Label("Tomorrow", systemImage: "calendar.badge.clock")
                }
            } label: {
                Label("Reschedule", systemImage: "calendar")
            }

            Divider()

            Button {
                onToggleComplete()
            } label: {
                Label(task.isCompleted ? "Mark incomplete" : "Mark complete", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle")
            }

            if let onDelete {
                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private var titleColor: Color {
        task.isCompleted || task.isPast ? DS.Colors.textTertiary : DS.Colors.textPrimary
    }

    private var secondaryTextColor: Color {
        DS.Colors.textSecondary
    }

    private var rowOpacity: Double {
        if task.isCompleted {
            return 0.55
        }
        if task.isPast {
            return 0.75
        }
        return 1
    }
}

// MARK: - Day View Task Pill
struct DayViewTaskPill: View {
    let task: TaskItem
    let height: CGFloat?
    private let pillWidth: CGFloat = DS.Sizes.taskPillDefault

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
                .scaledFont(size: 20, relativeTo: .title3)
        }
        .frame(width: pillWidth, height: pillHeight)
        .shadowColored(task.color.color)
    }

    private var pillHeight: CGFloat {
        if let height {
            return max(DS.Sizes.taskPillDefault, height)
        }

        let hours = CGFloat(task.duration) / 3600.0
        return max(DS.Sizes.taskPillDefault, hours * DS.Sizes.taskPillDefault)
    }
}

// MARK: - Compact Task Card (for timeline)
struct CompactTaskCard: View {
    let task: TaskItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(task.color.color)
                        .frame(width: 32, height: 32)

                    RoundedRectangle(cornerRadius: DS.Radius.sm)
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
                        .frame(width: 32, height: 32)

                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .stroke(task.color.color.saturated(by: 1.2), lineWidth: 1)
                        .frame(width: 32, height: 32)

                    Text(task.icon)
                        .scaledFont(size: 16, relativeTo: .headline)
                }
                .shadowColored(task.color.color)

                // Title
                Text(task.title)
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Time
                Text(task.startTimeFormatted)
                    .scaledFont(size: 12, design: .monospaced, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfacePrimary)
            .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sampleTask = TaskItem(
        title: "Gym Workout",
        icon: "🏋️",
        colorName: "sage",
        startTime: Date(),
        duration: 3600,
        energyLevel: 4
    )
    sampleTask.addSubtask("Warm up")
    sampleTask.addSubtask("Strength")

    return VStack(spacing: DS.Spacing.lg) {
        TaskCardView(
            task: sampleTask,
            onToggleComplete: {},
            onTap: {}
        )

        CompactTaskCard(task: sampleTask, onTap: {})
    }
    .padding()
    .background(DS.Colors.bgPrimary)
}
