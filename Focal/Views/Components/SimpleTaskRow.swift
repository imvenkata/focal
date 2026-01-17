import SwiftUI

/// A minimal task row for the "Up next" list in Calm Mode.
/// Shows only icon + title, with swipe-to-complete gesture.
struct SimpleTaskRow: View {
    let task: TodoItem
    let onTap: () -> Void
    let onComplete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isCompleting = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let completeThreshold: CGFloat = 80

    private var taskColor: Color {
        task.color.color
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Complete action background (revealed on swipe right)
            HStack {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Done")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                }
                .foregroundStyle(.white)
                .padding(.leading, DS.Spacing.lg)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DS.Colors.success)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .opacity(offset > 0 ? min(offset / completeThreshold, 1.0) : 0)

            // Main row content
            Button(action: onTap) {
                HStack(spacing: DS.Spacing.md) {
                    // Priority stripe
                    RoundedRectangle(cornerRadius: 2)
                        .fill(task.priorityEnum.accentColor.opacity(0.6))
                        .frame(width: 3, height: 32)

                    // Icon
                    Text(task.icon)
                        .font(.system(size: 22))

                    // Title
                    Text(task.title)
                        .scaledFont(size: 15, weight: .medium, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Colors.textTertiary)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.md)
                .background(DS.Colors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // Only allow right swipe
                        if value.translation.width > 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if offset > completeThreshold {
                            // Complete the task
                            withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                                isCompleting = true
                                offset = UIScreen.main.bounds.width
                            }
                            HapticManager.shared.notification(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onComplete()
                            }
                        } else {
                            // Reset position
                            withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title)")
        .accessibilityHint("Tap to view details, or swipe right to complete")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.sm) {
        SimpleTaskRow(
            task: TodoItem(title: "Grocery shopping", icon: "🛒", priority: .high),
            onTap: { print("Tap") },
            onComplete: { print("Complete") }
        )

        SimpleTaskRow(
            task: TodoItem(title: "Reply to email", icon: "📧", priority: .medium),
            onTap: { print("Tap") },
            onComplete: { print("Complete") }
        )

        SimpleTaskRow(
            task: TodoItem(title: "Take vitamins", icon: "💊", priority: .low),
            onTap: { print("Tap") },
            onComplete: { print("Complete") }
        )
    }
    .padding()
    .background(DS.Colors.background)
}
