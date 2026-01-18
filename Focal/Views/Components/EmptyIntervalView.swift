import SwiftUI

struct EmptyIntervalView: View {
    let gap: TimeInterval
    let startTime: Date
    let endTime: Date
    let minHeight: CGFloat
    let onAddTask: () -> Void
    let onTapToCreate: ((Date) -> Void)?
    let showsAddButton: Bool

    @State private var isPressed = false
    private let ctaMinimumGap: TimeInterval = 30 * 60

    init(
        gap: TimeInterval,
        startTime: Date,
        endTime: Date,
        minHeight: CGFloat,
        showsAddButton: Bool = true,
        onAddTask: @escaping () -> Void = {},
        onTapToCreate: ((Date) -> Void)? = nil
    ) {
        self.gap = gap
        self.startTime = startTime
        self.endTime = endTime
        self.minHeight = minHeight
        self.showsAddButton = showsAddButton
        self.onAddTask = onAddTask
        self.onTapToCreate = onTapToCreate
    }

    var body: some View {
        ZStack {
            // Tap target area with visual feedback
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(isPressed ? DS.Colors.primary.opacity(0.08) : Color.clear)
                .animation(DS.Animation.quick, value: isPressed)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                if showsCTA && showsAddButton {
                    AddTaskCTA(action: onAddTask)
                }
            }
            .padding(.leading, DS.Sizes.taskPillDefault + DS.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isTappable else { return }
            HapticManager.shared.selection()
            onTapToCreate?(startTime)
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            guard isTappable else { return }
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel("Empty time slot from \(startTime.formattedTime) to \(endTime.formattedTime)")
        .accessibilityHint(isTappable ? "Tap to add a task at this time" : "")
    }

    private var now: Date {
        Date()
    }

    private var showsCTA: Bool {
        gap >= ctaMinimumGap && endTime > now && minHeight >= DS.Sizes.minTouchTarget
    }

    /// Whether this empty interval can be tapped to create a task
    private var isTappable: Bool {
        onTapToCreate != nil && endTime > now && minHeight >= DS.Sizes.minTouchTarget
    }
}

private struct AddTaskCTA: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.warning)
                        .frame(width: DS.Spacing.xxl, height: DS.Spacing.xxl)

                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(.white)
                }

                Text("Add Task")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.warning)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfaceSecondary)
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
    .background(DS.Colors.bgPrimary)
}
