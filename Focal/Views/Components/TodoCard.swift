import SwiftUI

struct TodoCard: View {
    let todo: TodoItem
    let isExpanded: Bool
    let onToggleCompletion: () -> Void
    let onToggleExpand: () -> Void
    let onToggleSubtask: (TodoSubtask) -> Void
    let onDeleteSubtask: (TodoSubtask) -> Void
    let onAddSubtask: (String) -> Void

    @State private var newSubtaskText = ""
    @FocusState private var isAddingSubtask: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main todo row
            mainRow

            // Subtasks section (when expanded)
            if isExpanded && todo.hasSubtasks {
                subtasksSection
            }
        }
        .background(todo.color.lightColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(todo.color.color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Main Row

    private var mainRow: some View {
        Button(action: {
            if todo.hasSubtasks {
                onToggleExpand()
            }
        }) {
            HStack(spacing: DS.Spacing.md) {
                // Icon badge
                Text(todo.icon)
                    .font(.system(size: 24))

                // Title and progress
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(todo.title)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(todo.isCompleted ? DS.Colors.textSecondary : DS.Colors.textPrimary)
                        .strikethrough(todo.isCompleted)

                    if todo.hasSubtasks {
                        subtaskProgressView
                    }
                }

                Spacer()

                // Checkbox or Expand chevron
                if todo.hasSubtasks {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Colors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(DS.Animation.spring, value: isExpanded)
                } else {
                    checkboxView
                }
            }
            .padding(DS.Spacing.lg)
        }
        .buttonStyle(.plain)
    }

    private var checkboxView: some View {
        Button(action: onToggleCompletion) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        todo.isCompleted ? todo.color.color : DS.Colors.divider,
                        lineWidth: 2
                    )
                    .frame(width: 28, height: 28)

                if todo.isCompleted {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(todo.color.color)
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(todo.isCompleted ? "Mark incomplete" : "Mark complete")
    }

    private var subtaskProgressView: some View {
        HStack(spacing: DS.Spacing.xs) {
            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DS.Colors.divider)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(todo.color.color)
                        .frame(width: geometry.size.width * todo.subtasksProgress, height: 4)
                        .animation(DS.Animation.spring, value: todo.subtasksProgress)
                }
            }
            .frame(width: 60, height: 4)

            Text("\(todo.completedSubtasksCount)/\(todo.totalSubtasks)")
                .scaledFont(size: 11, weight: .medium, design: .monospaced, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textTertiary)
        }
    }

    // MARK: - Subtasks Section

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            // Divider
            Rectangle()
                .fill(todo.color.color.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, DS.Spacing.lg)

            // Subtask list
            ForEach(todo.subtasks.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.id) { subtask in
                TodoSubtaskRow(
                    subtask: subtask,
                    onToggle: { onToggleSubtask(subtask) },
                    onDelete: { onDeleteSubtask(subtask) }
                )
            }

            // Add subtask input
            addSubtaskRow
        }
        .padding(.bottom, DS.Spacing.sm)
    }

    private var addSubtaskRow: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(todo.color.color)

            TextField("Add subtask", text: $newSubtaskText)
                .scaledFont(size: 14, relativeTo: .subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
                .focused($isAddingSubtask)
                .submitLabel(.done)
                .onSubmit {
                    addSubtask()
                }
        }
        .padding(.leading, DS.Spacing.xxxl + DS.Spacing.sm)
        .padding(.trailing, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.sm)
    }

    private func addSubtask() {
        guard !newSubtaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onAddSubtask(newSubtaskText)
        newSubtaskText = ""
        isAddingSubtask = false
    }
}
