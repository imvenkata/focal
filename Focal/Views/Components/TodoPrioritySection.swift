import SwiftUI

struct TodoPrioritySection: View {
    let priority: TodoPriority
    let todos: [TodoItem]
    let isCollapsed: Bool
    let onToggleCollapse: () -> Void
    let onToggleCompletion: (TodoItem) -> Void
    let onAddTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Section Header - Tiimo-style pill badge
            HStack {
                Button(action: {
                    withAnimation(DS.Animation.spring) {
                        onToggleCollapse()
                    }
                }) {
                    HStack(spacing: DS.Spacing.xs) {
                        // Priority icon
                        Text(priority.icon)
                            .font(.system(size: 10))
                            .foregroundStyle(priority.iconColor)

                        // Label
                        Text(priority.displayName.uppercased())
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textPrimary)
                            .tracking(0.5)

                        // Count
                        Text("(\(todos.count))")
                            .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        // Chevron
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.Colors.textTertiary)
                            .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.sm)
                    .background(priority.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)

                Spacer()

                // Add button
                Button(action: onAddTapped) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DS.Colors.textTertiary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .opacity(0.6)
            }
            .padding(.horizontal, DS.Spacing.xs)

            // Tasks list (when expanded)
            if !isCollapsed {
                VStack(spacing: DS.Spacing.sm) {
                    ForEach(todos, id: \.id) { todo in
                        TiimoTodoCard(
                            todo: todo,
                            onToggleCompletion: { onToggleCompletion(todo) }
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Tiimo-Style Todo Card

struct TiimoTodoCard: View {
    let todo: TodoItem
    let onToggleCompletion: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Emoji badge
            Text(todo.icon)
                .font(.system(size: 22))
                .frame(width: 44, height: 44)
                .background(todo.color.lightColor.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

            // Title
            Text(todo.title)
                .scaledFont(size: 15, weight: .medium, relativeTo: .body)
                .foregroundStyle(todo.isCompleted ? DS.Colors.textSecondary : DS.Colors.textPrimary)
                .strikethrough(todo.isCompleted)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Circular checkbox
            Button(action: onToggleCompletion) {
                ZStack {
                    Circle()
                        .stroke(todo.isCompleted ? Color.clear : DS.Colors.divider, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if todo.isCompleted {
                        Circle()
                            .fill(DS.Colors.sage)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .shadowResting()
        .opacity(todo.isCompleted ? 0.6 : 1)
    }
}
