import SwiftUI

/// A large, prominent card displaying the user's current focus task in Calm Mode.
/// Features a large emoji, clear title, and two action buttons.
struct HeroTaskCard: View {
    let task: TodoItem
    let onComplete: () -> Void
    let onLater: () -> Void
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var showCompletionAnimation = false

    private var taskColor: Color {
        task.color.color
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            // Header label
            Text("YOUR FOCUS")
                .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textTertiary)
                .tracking(1.5)

            // Main content
            Button(action: onTap) {
                VStack(spacing: DS.Spacing.lg) {
                    // Large emoji
                    Text(task.icon)
                        .font(.system(size: 64))
                        .scaleEffect(showCompletionAnimation ? 1.2 : 1.0)

                    // Task title
                    Text(task.title)
                        .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    // Gentle encouragement (no pressure)
                    Text("Take your time")
                        .scaledFont(size: 13, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.xxl)
                .padding(.horizontal, DS.Spacing.lg)
            }
            .buttonStyle(.plain)

            // Action buttons
            HStack(spacing: DS.Spacing.md) {
                // Done button
                Button {
                    completeTask()
                } label: {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Done!")
                            .scaledFont(size: 15, weight: .semibold, relativeTo: .callout)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                            .fill(DS.Colors.success)
                    )
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel("Mark as done")
                .accessibilityHint("Completes this task")

                // Later button
                Button {
                    onLater()
                    HapticManager.shared.selection()
                } label: {
                    Text("Later")
                        .scaledFont(size: 15, weight: .medium, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                .fill(DS.Colors.surfaceSecondary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                        )
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel("Do this later")
                .accessibilityHint("Skips to the next task")
            }
        }
        .padding(DS.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [taskColor.opacity(0.08), taskColor.opacity(0.03)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.xxxl))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous)
                .stroke(taskColor.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Focus task: \(task.title)")
    }

    private func completeTask() {
        // Trigger animation
        withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.bounce) {
            showCompletionAnimation = true
        }

        HapticManager.shared.notification(.success)

        // Delay completion callback to show animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

#Preview {
    let task = TodoItem(
        title: "Read chapter 3 of the physics book",
        icon: "📚",
        colorName: "lavender",
        priority: .medium
    )

    return VStack {
        HeroTaskCard(
            task: task,
            onComplete: { print("Complete") },
            onLater: { print("Later") },
            onTap: { print("Tap") }
        )
        .padding()
    }
    .background(DS.Colors.background)
}
