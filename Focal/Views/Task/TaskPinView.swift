import SwiftUI

struct TaskPinView: View {
    let task: TaskItem
    var size: CGFloat = DS.Sizes.taskPillSmall
    var showTitle: Bool = false

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            // Pill
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(task.color.color)
                    .frame(width: size, height: size)
                    .shadow(color: task.color.color.opacity(0.3), radius: 8, y: 4)

                Text(task.icon)
                    .scaledFont(size: size * 0.5, relativeTo: .title3)
            }
            .opacity(task.isCompleted ? 0.5 : 1)
            .overlay {
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .scaledFont(size: size * 0.4, weight: .bold, relativeTo: .callout)
                        .foregroundStyle(.white)
                }
            }

            // Title
            if showTitle {
                Text(task.title)
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: size + 10)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.startTimeFormatted)")
        .accessibilityAddTraits(task.isCompleted ? .isSelected : [])
    }
}

// MARK: - Mini Task Pin (for week view)
struct MiniTaskPin: View {
    let task: TaskItem
    let size: CGFloat = 36
    var hourHeight: CGFloat = 60
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 3) {
            // Task pill with Apple design principles
            ZStack {
                // Background with elevation
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(task.color.color)
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    .shadow(color: task.color.color.opacity(0.25), radius: 6, y: 3)
                
                // Icon with proper contrast
                Text(task.icon)
                    .scaledFont(size: 16, relativeTo: .headline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
            }
            .opacity(task.isCompleted ? 0.6 : 1)
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .overlay {
                if task.isCompleted {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "checkmark")
                            .scaledFont(size: 10, weight: .bold, relativeTo: .caption2)
                            .foregroundStyle(.white)
                    }
                }
            }
            
            // Duration bar with refined styling
            if task.duration > 1800 { // > 0.5 hours
                let barHeight = durationBarHeight
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                task.color.color.opacity(0.7),
                                task.color.color.opacity(0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4)
                    .frame(height: max(barHeight, 6))
                    .shadow(color: task.color.color.opacity(0.2), radius: 1, y: 1)
            }
        }
        .accessibilityLabel("\(task.title), \(task.durationFormatted)")
    }
    
    private var durationBarHeight: CGFloat {
        // Calculate bar height based on duration
        // Subtract pill height + spacing to avoid overlap
        let durationInHours = task.duration / 3600.0
        let totalHeight = CGFloat(durationInHours) * hourHeight
        return max(totalHeight - 42, 6) // 42 = pill + spacing
    }
}

#Preview {
    let sampleTask = TaskItem(
        title: "Gym",
        icon: "🏋️",
        colorName: "sage",
        startTime: Date()
    )

    VStack(spacing: DS.Spacing.xl) {
        TaskPinView(task: sampleTask, size: 56, showTitle: true)
        TaskPinView(task: sampleTask, size: 40)
        MiniTaskPin(task: sampleTask)
    }
    .padding()
    .background(DS.Colors.background)
}
