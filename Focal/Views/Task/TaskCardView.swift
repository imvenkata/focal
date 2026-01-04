import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    let onDelete: (() -> Void)?

    init(
        task: TaskItem,
        onToggleComplete: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.task = task
        self.onToggleComplete = onToggleComplete
        self.onTap = onTap
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.lg) {
            Button {
                onTap()
            } label: {
                HStack(alignment: .top, spacing: DS.Spacing.lg) {
                    // Task pill - scaled by duration
                    DayViewTaskPill(task: task)
                    
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
                                    .background(DS.Colors.divider.opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }

                        // Title
                        Text(task.title)
                            .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                            .foregroundStyle(titleColor)
                            .strikethrough(task.isCompleted, color: secondaryTextColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
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
                            .fill(DS.Colors.emerald500)
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
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.sm)
        .background(task.isActive ? task.color.lightColor.opacity(0.5) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
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
            .tint(task.isCompleted ? DS.Colors.slate : DS.Colors.sage)
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
    }

    private var titleColor: Color {
        task.isCompleted || task.isPast ? DS.Colors.stone500 : DS.Colors.stone800
    }

    private var secondaryTextColor: Color {
        DS.Colors.stone400
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(task.color.color)
                .frame(width: 56)
                .frame(height: pillHeight)
                .shadow(color: task.color.color.opacity(0.15), radius: 4, y: 2)
            
            Text(task.icon)
                .scaledFont(size: 24, relativeTo: .title2)
        }
    }
    
    private var pillHeight: CGFloat {
        // 56px default, scales with duration
        // React: Math.max(56, task.duration * 60)
        if task.duration > 1800 { // > 0.5 hours
            return max(56, CGFloat(task.duration) / 3600.0 * 60)
        } else {
            return 56
        }
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
                        .fill(task.color.lightColor)
                        .frame(width: 36, height: 36)

                    Text(task.icon)
                        .scaledFont(size: 18, relativeTo: .headline)
                }

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
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
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
    .background(DS.Colors.background)
}
