import SwiftUI

struct TodoSubtaskRow: View {
    let subtask: TodoSubtask
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Small checkbox (dopamine hit size - 20px)
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            subtask.isCompleted ? DS.Colors.sage : DS.Colors.divider,
                            lineWidth: 1.5
                        )
                        .frame(width: 20, height: 20)

                    if subtask.isCompleted {
                        Circle()
                            .fill(DS.Colors.sage)
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Title
            Text(subtask.title)
                .scaledFont(size: 14, relativeTo: .subheadline)
                .foregroundStyle(subtask.isCompleted ? DS.Colors.textTertiary : DS.Colors.textSecondary)
                .strikethrough(subtask.isCompleted)

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .opacity(0.6)
        }
        .padding(.leading, DS.Spacing.xxxl + DS.Spacing.sm) // Indented for visual hierarchy
        .padding(.trailing, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.xs)
    }
}
