import SwiftUI

/// A clean, minimal task card for ungrouped todo list view.
/// Shows priority color line, checkbox, title, duration, and optional meta info.
struct SimpleTodoCard: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false
    @State private var offset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let deleteThreshold: CGFloat = 100
    private let checkboxSize: CGFloat = 32

    private var priorityColor: Color {
        todo.priorityEnum.accentColor
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete action background (revealed on swipe left)
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: max(offset, 0))
            }
            .frame(maxHeight: .infinity)
            .background(DS.Colors.danger)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .opacity(offset > 0 ? 1 : 0)

            // Main card content
            HStack(spacing: 0) {
                // Priority color stripe
                RoundedRectangle(cornerRadius: 2)
                    .fill(priorityColor.opacity(todo.isCompleted ? 0.3 : 0.8))
                    .frame(width: 4)
                    .padding(.vertical, DS.Spacing.sm)

                HStack(spacing: DS.Spacing.md) {
                    // Checkbox
                    Button(action: {
                        onToggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                .stroke(
                                    todo.isCompleted ? DS.Colors.success : DS.Colors.borderStrong,
                                    lineWidth: 2
                                )
                                .frame(width: checkboxSize, height: checkboxSize)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                        .fill(todo.isCompleted ? DS.Colors.success : Color.clear)
                                )

                            if todo.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(todo.isCompleted ? "Completed" : "Not completed")
                    .accessibilityHint("Double tap to toggle completion")

                    // Content
                    Button(action: onTap) {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            // Title row with duration
                            HStack(alignment: .center, spacing: DS.Spacing.sm) {
                                // Icon
                                Text(todo.icon)
                                    .font(.system(size: 18))

                                // Title
                                Text(todo.title)
                                    .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                                    .foregroundStyle(todo.isCompleted ? DS.Colors.textTertiary : DS.Colors.textPrimary)
                                    .strikethrough(todo.isCompleted, color: DS.Colors.textTertiary)
                                    .lineLimit(1)

                                Spacer()

                                // Duration badge (if exists)
                                if let duration = todo.estimatedDurationFormatted {
                                    Text(duration)
                                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                                        .foregroundStyle(DS.Colors.textTertiary)
                                        .padding(.horizontal, DS.Spacing.sm)
                                        .padding(.vertical, DS.Spacing.xs)
                                        .background(DS.Colors.surfaceSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
                                }
                            }

                            // Meta info row (only if due date exists)
                            if let dueLabel = dueDateLabel, !todo.isCompleted {
                                HStack(spacing: DS.Spacing.xs) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11, weight: .medium))
                                    Text(dueLabel)
                                        .scaledFont(size: 12, relativeTo: .caption)
                                }
                                .foregroundStyle(dueDateColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, DS.Spacing.md)
                .padding(.trailing, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.md)
            }
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(x: -offset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // Only allow left swipe (negative translation)
                        if value.translation.width < 0 {
                            offset = -value.translation.width
                        }
                    }
                    .onEnded { _ in
                        if offset > deleteThreshold {
                            // Delete
                            withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                                offset = UIScreen.main.bounds.width
                            }
                            HapticManager.shared.notification(.warning)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDelete()
                            }
                        } else {
                            // Reset
                            withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(todo.title), \(todo.isCompleted ? "completed" : "not completed")")
        .accessibilityHint("Swipe left to delete")
    }

    // MARK: - Computed Properties

    private var dueDateLabel: String? {
        guard todo.dueDate != nil else { return nil }

        if todo.isDueToday {
            if let time = todo.dueTimeFormatted {
                return "Today, \(time)"
            }
            return "Today"
        } else if todo.isDueTomorrow {
            return "Tomorrow"
        } else if todo.isOverdue {
            return "Overdue"
        } else if let formatted = todo.dueDateFormatted {
            return formatted
        }
        return nil
    }

    private var dueDateColor: Color {
        if todo.isOverdue {
            return DS.Colors.danger
        } else if todo.isDueToday {
            return DS.Colors.amber
        }
        return DS.Colors.textTertiary
    }
}

#Preview {
    VStack(spacing: DS.Spacing.sm) {
        SimpleTodoCard(
            todo: {
                let t = TodoItem(title: "Reply to Sarah's email", icon: "📧", priority: .high)
                t.setDueDate(Date())
                t.estimatedDuration = 5 * 60
                return t
            }(),
            onToggle: {},
            onTap: {},
            onDelete: {}
        )

        SimpleTodoCard(
            todo: {
                let t = TodoItem(title: "Weekly grocery shopping", icon: "🛒", priority: .medium)
                t.estimatedDuration = 45 * 60
                return t
            }(),
            onToggle: {},
            onTap: {},
            onDelete: {}
        )

        SimpleTodoCard(
            todo: {
                let t = TodoItem(title: "Read physics chapter", icon: "📚", priority: .low)
                t.toggleCompletion()
                return t
            }(),
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
    }
    .padding()
    .background(DS.Colors.background)
}
