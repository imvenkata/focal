import SwiftUI

struct EmptyIntervalView: View {
    let gap: TimeInterval
    let startTime: Date
    let endTime: Date
    let minHeight: CGFloat
    let onAddTask: () -> Void

    private let ctaMinimumGap: TimeInterval = 30 * 60
    private let upcomingThreshold: TimeInterval = 15 * 60
    
    private enum MessageStyle {
        case upcoming(TimeInterval)
        case wellSpent
        case breakTime
        case freeTime
    }

    init(
        gap: TimeInterval,
        startTime: Date,
        endTime: Date,
        minHeight: CGFloat,
        onAddTask: @escaping () -> Void = {}
    ) {
        self.gap = gap
        self.startTime = startTime
        self.endTime = endTime
        self.minHeight = minHeight
        self.onAddTask = onAddTask
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.xs) {
                Text(messageIcon)
                    .scaledFont(size: 12, relativeTo: .caption)
                    .accessibilityHidden(true)

                messageText
            }

            if showsCTA {
                AddTaskCTA(action: onAddTask)
            }
        }
        .padding(.leading, DS.Sizes.taskPillDefault + DS.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(messageAccessibilityLabel)
    }

    private var now: Date {
        Date()
    }

    private var isCurrentGap: Bool {
        startTime <= now && endTime >= now
    }

    private var showsCTA: Bool {
        gap >= ctaMinimumGap && endTime > now && minHeight >= DS.Sizes.minTouchTarget
    }

    private var messageStyle: MessageStyle {
        if isCurrentGap {
            let remaining = endTime.timeIntervalSince(now)
            return remaining >= upcomingThreshold ? .upcoming(remaining) : .breakTime
        }

        if gap >= 2 * 3600 {
            return .freeTime
        }

        if gap >= 45 * 60 {
            return .wellSpent
        }

        return .breakTime
    }

    private var messageIcon: String {
        switch messageStyle {
        case .upcoming:
            return "⏰"
        case .wellSpent:
            return "💤"
        case .breakTime:
            return "☕"
        case .freeTime:
            return "🌟"
        }
    }

    @ViewBuilder
    private var messageText: some View {
        switch messageStyle {
        case .upcoming(let remaining):
            (
                Text("Use ")
                    .foregroundStyle(DS.Colors.stone500)
                + Text(remaining.formattedDuration)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.amber)
                + Text(", task approaching.")
                    .foregroundStyle(DS.Colors.stone500)
            )
            .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
        case .wellSpent:
            Text("A well-spent interval.")
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.stone500)
                .italic()
        case .breakTime:
            Text("Time for a break.")
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.stone500)
                .italic()
        case .freeTime:
            Text("Free time - you earned it!")
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.stone500)
                .italic()
        }
    }

    private var messageAccessibilityLabel: String {
        switch messageStyle {
        case .upcoming(let remaining):
            return "Free time. Use \(remaining.formattedDuration) before the next task."
        case .wellSpent:
            return "Free time interval. A well-spent interval."
        case .breakTime:
            return "Free time interval. Time for a break."
        case .freeTime:
            return "Free time interval. Free time, you earned it."
        }
    }
}

private struct AddTaskCTA: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.amber)
                        .frame(width: DS.Spacing.xxl, height: DS.Spacing.xxl)

                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(.white)
                }

                Text("Add Task")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.amber)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.stone50)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add task")
        .accessibilityHint("Opens the new task sheet")
    }
}

#Preview {
    let now = Date()

    return VStack(spacing: DS.Spacing.xl) {
        EmptyIntervalView(
            gap: 2 * 3600,
            startTime: now.addingTimeInterval(-3 * 3600),
            endTime: now.addingTimeInterval(-3600),
            minHeight: 120
        )

        EmptyIntervalView(
            gap: 3.5 * 3600,
            startTime: now,
            endTime: now.addingTimeInterval(3.5 * 3600),
            minHeight: 160
        )

        EmptyIntervalView(
            gap: 30 * 60,
            startTime: now.addingTimeInterval(4 * 3600),
            endTime: now.addingTimeInterval(4.5 * 3600),
            minHeight: 80
        )
    }
    .padding()
    .background(DS.Colors.background)
}
