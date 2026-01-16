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
    let onAddItem: () -> Void
    let onDropItem: (TodoItem) -> Void
    var onReorder: ((Int, Int) -> Void)? = nil

    @State private var isHovering = false
    @State private var draggedItem: TodoItem?

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

                // Add button - triggers callback
                Button(action: onAddItem) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DS.Colors.textTertiary)
                        .frame(width: 28, height: 28)
                        .background(Color.clear)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .opacity(isHovering || !todos.isEmpty ? 1 : 0.5)
            }
            .padding(.horizontal, DS.Spacing.xs)

            // Tasks list and drop zone
            VStack(spacing: DS.Spacing.sm) {
                if !isCollapsed {
                    ForEach(Array(todos.enumerated()), id: \.element.id) { index, todo in
                        DraggableTodoCard(
                            todo: todo,
                            onToggleCompletion: { onToggleCompletion(todo) },
                            onTap: { onTap(todo) },
                            onDelete: { onDelete(todo) }
                        )
                        .opacity(draggedItem?.id == todo.id ? 0.5 : 1.0)
                        .onDrag {
                            draggedItem = todo
                            HapticManager.shared.dragActivated()
                            return NSItemProvider(object: todo.id.uuidString as NSString)
                        }
                        .onDrop(of: [.text], delegate: ReorderDropDelegate(
                            item: todo,
                            items: todos,
                            currentIndex: index,
                            draggedItem: $draggedItem,
                            onReorder: onReorder
                        ))
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
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .animation(DS.Animation.spring, value: isDropTarget)
    }
}

// MARK: - Draggable Todo Card

struct DraggableTodoCard: View {
    let todo: TodoItem
    let onToggleCompletion: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    
    private let swipeThreshold: CGFloat = 80
    private let deleteThreshold: CGFloat = 120

    var body: some View {
        ZStack(alignment: .trailing) {
            // Background actions (revealed on swipe)
            HStack(spacing: 0) {
                // Left side - Complete action
                Button(action: {
                    withAnimation(DS.Animation.spring) {
                        offset = 0
                    }
                    onToggleCompletion()
                }) {
                    ZStack {
                        DS.Colors.success
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: abs(min(offset, 0)))
                }
                .buttonStyle(.plain)
                .opacity(offset < 0 ? 1 : 0)
                
                Spacer()
                
                // Right side - Delete action
                Button(action: {
                    withAnimation(DS.Animation.spring) {
                        offset = 0
                    }
                    onDelete()
                }) {
                    ZStack {
                        DS.Colors.danger
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: max(offset, 0))
                }
                .buttonStyle(.plain)
                .opacity(offset > 0 ? 1 : 0)
            }
            .frame(maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            
            // Main card content
            TiimoTodoCard(
                todo: todo,
                onToggleCompletion: onToggleCompletion,
                onTap: onTap
            )
            .offset(x: -offset)
            .draggable(todo.id.uuidString) {
                // Drag preview for priority reordering
                TiimoTodoCard(todo: todo, onToggleCompletion: {}, onTap: {})
                    .frame(width: 300)
                    .opacity(0.9)
                    .scaleEffect(0.95)
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // Only horizontal swipes
                        if abs(value.translation.width) > abs(value.translation.height) {
                            isSwiping = true
                            offset = -value.translation.width
                        }
                    }
                    .onEnded { value in
                        isSwiping = false
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        
                        withAnimation(DS.Animation.spring) {
                            // Swipe left (delete)
                            if offset > deleteThreshold || velocity < -300 {
                                offset = 0
                                onDelete()
                            }
                            // Swipe right (complete)
                            else if offset < -swipeThreshold || velocity > 300 {
                                offset = 0
                                onToggleCompletion()
                            }
                            // Snap back
                            else {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Tiimo-Style Todo Card

struct TiimoTodoCard: View {
    let todo: TodoItem
    let onToggleCompletion: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Priority stripe on the left edge
                Rectangle()
                    .fill(todo.priorityEnum.accentColor)
                    .frame(width: 4)

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
                            categoryTag

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
            }
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadowResting()
            .opacity(todo.isCompleted ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(todo.title), category \(todo.categoryEnum.label), priority \(todo.priorityEnum.displayName)")
        .accessibilityHint("Tap to view details")
    }

    private var categoryTag: some View {
        let category = todo.categoryEnum
        return HStack(spacing: DS.Spacing.xs) {
            Text(category.icon)
                .scaledFont(size: 10, relativeTo: .caption2)
            Text(category.label)
                .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
        }
        .foregroundStyle(category.tint)
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.vertical, DS.Spacing.xs / 2)
        .background(category.tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }
}

// MARK: - Reorder Drop Delegate

struct ReorderDropDelegate: DropDelegate {
    let item: TodoItem
    let items: [TodoItem]
    let currentIndex: Int
    @Binding var draggedItem: TodoItem?
    var onReorder: ((Int, Int) -> Void)?

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.id != item.id,
              let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }),
              fromIndex != toIndex else { return }

        HapticManager.shared.selection()
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem,
              let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }),
              fromIndex != toIndex else {
            self.draggedItem = nil
            return false
        }

        onReorder?(fromIndex, toIndex)
        HapticManager.shared.dragDropped()
        self.draggedItem = nil
        return true
    }

    func dropExited(info: DropInfo) {
        // No action needed
    }
}
