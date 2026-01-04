import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onToggleComplete: () -> Void
    let onTap: () -> Void

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
                            .foregroundStyle(DS.Colors.textSecondary)

                            if task.duration > 1800 {
                            Text("(\(task.durationFormatted))")
                                .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DS.Colors.divider.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                        // Title
                    Text(task.title)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textPrimary)
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
                            .fill(Color(hex: "#10B981")) // emerald-500
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
        .padding(.vertical, DS.Spacing.md)
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
