import SwiftUI

struct TodoPrioritySection: View {
    let priority: TodoPriority
    let todos: [TodoItem]
    let isCollapsed: Bool
    let isDropTarget: Bool
    let onToggleCollapse: () -> Void
    let onToggleCompletion: (TodoItem) -> Void
    let onTap: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    let onAddItem: (String) -> Void
    let onDropItem: (TodoItem) -> Void

    @State private var isAdding = false
    @State private var newItemText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Section Header - Tiimo-style pill badge
            HStack {
                Button(action: {
                    withAnimation(DS.Animation.spring) {
                        onToggleCollapse()
                    }
                }) {
                    HStack(spacing: DS.Spacing.sm) {
                        // Priority icon (optional for "To-do" section)
                        if let icon = priority.icon {
                            Text(icon)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(priority.iconColor)
                        }

                        // Label
                        Text(priority.displayName.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(priority.badgeTextColor)
                            .tracking(0.8)

                        // Count
                        Text("(\(todos.count))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(priority.badgeTextColor.opacity(0.7))

                        // Chevron
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(priority.badgeTextColor.opacity(0.6))
                            .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.sm)
                    .background(priority.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(isDropTarget ? priority.accentColor : priority.iconColor.opacity(0.3), lineWidth: isDropTarget ? 2 : 1)
                    )
                    .scaleEffect(isDropTarget ? 1.02 : 1.0)
                }
                .buttonStyle(.plain)

                Spacer()

                // Add button - toggles inline input
                Button(action: {
                    withAnimation(DS.Animation.spring) {
                        isAdding.toggle()
                        if isAdding {
                            isInputFocused = true
                        }
                    }
                }) {
                    Image(systemName: isAdding ? "xmark" : "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isAdding ? DS.Colors.textSecondary : DS.Colors.textTertiary)
                        .frame(width: 28, height: 28)
                        .background(isAdding ? DS.Colors.bgSecondary : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DS.Spacing.xs)

            // Inline add input
            if isAdding {
                HStack(spacing: DS.Spacing.md) {
                    TextField("Add to \(priority.displayName)...", text: $newItemText)
                        .scaledFont(size: 15, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            addItem()
                        }

                    Button(action: addItem) {
                        Text("Add")
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(newItemText.isEmpty ? DS.Colors.textTertiary : priority.iconColor)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                    .buttonStyle(.plain)
                    .disabled(newItemText.isEmpty)
                }
                .padding(DS.Spacing.md)
                .background(DS.Colors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .stroke(priority.iconColor.opacity(0.3), lineWidth: 1.5)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            // Tasks list and drop zone
            VStack(spacing: DS.Spacing.sm) {
                if !isCollapsed {
                    ForEach(todos, id: \.id) { todo in
                        DraggableTodoCard(
                            todo: todo,
                            onToggleCompletion: { onToggleCompletion(todo) },
                            onTap: { onTap(todo) },
                            onDelete: { onDelete(todo) }
                        )
                    }
                }

                // Drop zone indicator when dragging
                if isDropTarget {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(priority.accentColor)
                        Text("Drop here to move to \(priority.displayName)")
                            .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
                            .foregroundStyle(priority.accentColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DS.Spacing.lg)
                    .background(priority.badgeBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.lg)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                            .foregroundStyle(priority.accentColor)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .animation(DS.Animation.spring, value: isDropTarget)
    }

    private func addItem() {
        guard !newItemText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onAddItem(newItemText)
        newItemText = ""
        withAnimation(DS.Animation.spring) {
            isAdding = false
        }
    }
}

// MARK: - Draggable Todo Card

struct DraggableTodoCard: View {
    let todo: TodoItem
    let onToggleCompletion: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var isDragging = false

    var body: some View {
        TiimoTodoCard(
            todo: todo,
            onToggleCompletion: onToggleCompletion,
            onTap: onTap
        )
        .draggable(todo.id.uuidString) {
            // Drag preview
            TiimoTodoCard(todo: todo, onToggleCompletion: {}, onTap: {})
                .frame(width: 300)
                .opacity(0.9)
                .scaleEffect(0.95)
        }
        .opacity(isDragging ? 0.5 : 1)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(DS.Colors.danger)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onToggleCompletion) {
                Label("Complete", systemImage: "checkmark.circle.fill")
            }
            .tint(DS.Colors.success)
        }
    }
}

// MARK: - Tiimo-Style Todo Card

struct TiimoTodoCard: View {
    let todo: TodoItem
    let onToggleCompletion: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.md) {
                // Emoji badge
                Text(todo.icon)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(todo.color.lightColor.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

                // Title and metadata
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(todo.title)
                        .scaledFont(size: 15, weight: .medium, relativeTo: .body)
                        .foregroundStyle(todo.isCompleted ? DS.Colors.textSecondary : DS.Colors.textPrimary)
                        .strikethrough(todo.isCompleted)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Due date and subtasks info
                    HStack(spacing: DS.Spacing.sm) {
                        if let dueText = todo.dueDateFormatted {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: todo.isOverdue ? "exclamationmark.circle.fill" : "calendar")
                                    .font(.system(size: 10, weight: .semibold))
                                Text(dueText)
                                    .scaledFont(size: 11, weight: .medium, relativeTo: .caption2)
                            }
                            .foregroundStyle(todo.isOverdue ? DS.Colors.danger : DS.Colors.textTertiary)
                        }

                        if todo.hasSubtasks {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("\(todo.completedSubtasksCount)/\(todo.totalSubtasks)")
                                    .scaledFont(size: 11, weight: .medium, design: .monospaced, relativeTo: .caption2)
                            }
                            .foregroundStyle(DS.Colors.textTertiary)
                        }

                        if todo.reminderOption != nil {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(DS.Colors.textTertiary)
                        }
                    }
                }

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
        .buttonStyle(.plain)
        .accessibilityLabel("\(todo.title), priority \(todo.priorityEnum.displayName)")
        .accessibilityHint("Tap to view details")
    }
}
