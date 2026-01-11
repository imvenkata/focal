import SwiftUI

struct TodoPrioritySection: View {
    let priority: TodoPriority
    let todos: [TodoItem]
    let expandedIds: Set<UUID>
    let onToggleCompletion: (TodoItem) -> Void
    let onToggleExpand: (TodoItem) -> Void
    let onToggleSubtask: (TodoSubtask, TodoItem) -> Void
    let onDeleteSubtask: (TodoSubtask, TodoItem) -> Void
    let onAddSubtask: (String, TodoItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Priority header
            HStack(spacing: DS.Spacing.sm) {
                Text(priority.icon)
                    .font(.system(size: 16))

                Text(priority.displayName)
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .textCase(.uppercase)

                Text("(\(todos.count))")
                    .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textTertiary)
            }
            .padding(.horizontal, DS.Spacing.lg)

            // Todo cards
            if !todos.isEmpty {
                VStack(spacing: DS.Spacing.sm) {
                    ForEach(todos, id: \.id) { todo in
                        TodoCard(
                            todo: todo,
                            isExpanded: expandedIds.contains(todo.id),
                            onToggleCompletion: { onToggleCompletion(todo) },
                            onToggleExpand: { onToggleExpand(todo) },
                            onToggleSubtask: { subtask in onToggleSubtask(subtask, todo) },
                            onDeleteSubtask: { subtask in onDeleteSubtask(subtask, todo) },
                            onAddSubtask: { title in onAddSubtask(title, todo) }
                        )
                    }
                }
            } else {
                // Empty state for this priority
                Text("No \(priority.displayName.lowercased()) priority todos")
                    .scaledFont(size: 14, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textTertiary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DS.Spacing.md)
            }
        }
    }
}
