import SwiftUI

struct SubtaskRow: View {
    let subtask: Subtask
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(subtask.isCompleted ? DS.Colors.sage : DS.Colors.divider, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if subtask.isCompleted {
                        Circle()
                            .fill(DS.Colors.sage)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .scaledFont(size: 12, weight: .bold, relativeTo: .caption)
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(subtask.isCompleted ? "Mark incomplete" : "Mark complete")
            
            // Title
            Text(subtask.title)
                .scaledFont(size: 15, relativeTo: .subheadline)
                .foregroundStyle(subtask.isCompleted ? DS.Colors.textSecondary : DS.Colors.textPrimary)
                .strikethrough(subtask.isCompleted)
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .scaledFont(size: 18, relativeTo: .headline)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .opacity(0.7)
            .accessibilityLabel("Delete subtask")
        }
        .padding(.vertical, DS.Spacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(subtask.title), \(subtask.isCompleted ? "completed" : "pending")")
    }
}

#Preview {
    let subtask1 = Subtask(title: "Warm up")
    subtask1.isCompleted = true
    
    let subtask2 = Subtask(title: "Main workout")
    
    return VStack(spacing: DS.Spacing.md) {
        SubtaskRow(
            subtask: subtask1,
            onToggle: {},
            onDelete: {}
        )
        
        SubtaskRow(
            subtask: subtask2,
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
    .background(DS.Colors.background)
}
