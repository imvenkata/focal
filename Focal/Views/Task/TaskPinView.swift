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
    var hourHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            LiquidGlassCapsuleView(
                title: task.title,
                time: task.startTimeFormatted,
                icon: task.icon,
                accentColor: task.color.color
            )
            .opacity(task.isCompleted ? 0.6 : 1)
            
            if task.duration > 1800 { // > 0.5 hours
                GlassStemView(height: durationStemHeight, accentColor: task.color.color)
                    .opacity(task.isPast ? 0.35 : 0.7)
            }
        }
        .accessibilityLabel("\(task.title), \(task.startTimeFormatted)")
    }
    
    private var durationStemHeight: CGFloat {
        let durationInHours = task.duration / 3600.0
        let totalHeight = CGFloat(durationInHours) * hourHeight
        let reservedHeight = DS.Sizes.glassCapsuleHeight + DS.Spacing.xs
        return max(totalHeight - reservedHeight, DS.Spacing.sm)
    }
}

// MARK: - Liquid Glass Capsule
struct LiquidGlassCapsuleView: View {
    let title: String
    let time: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(0.2),
                            Color.clear
                        ]),
                        center: .bottom,
                        startRadius: 0,
                        endRadius: DS.Sizes.glassCapsuleHeight
                    )
                )
            
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DS.Colors.glassFillStrong,
                                DS.Colors.glassFill,
                                DS.Colors.glassFillLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Capsule()
                    .stroke(DS.Colors.glassStroke, lineWidth: DS.Sizes.hairline)
            }
            .overlay(alignment: .top) {
                topEdgeHighlight
            }
            .overlay(alignment: .top) {
                innerCurveHighlight
            }
            .clipShape(Capsule())
            .shadow(color: DS.Colors.glassShadow, radius: 12, y: 4)
        }
        .frame(width: DS.Sizes.glassCapsuleWidth, height: DS.Sizes.glassCapsuleHeight)
        .overlay(content)
    }
    
    private var content: some View {
        VStack(spacing: DS.Spacing.xs) {
            GlassIconPip(icon: icon, accentColor: accentColor)
            
            VStack(spacing: DS.Spacing.xs) {
                Text(time)
                    .scaledFont(size: 8, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .tracking(0.2)
                
                Text(title)
                    .scaledFont(size: 9, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
        .padding(.horizontal, DS.Spacing.xs)
    }
    
    private var topEdgeHighlight: some View {
        LinearGradient(
            colors: [
                Color.clear,
                DS.Colors.glassHighlight,
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: DS.Sizes.hairline)
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.top, DS.Spacing.xs)
    }
    
    private var innerCurveHighlight: some View {
        RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        DS.Colors.glassCurveHighlight,
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: DS.Sizes.glassIconSize)
            .padding(.horizontal, DS.Spacing.xs)
            .padding(.top, DS.Spacing.xs)
    }
}

struct GlassIconPip: View {
    let icon: String
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(DS.Colors.glassFill)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(0.16),
                            Color.clear
                        ]),
                        center: .bottom,
                        startRadius: 0,
                        endRadius: DS.Sizes.glassIconSize
                    )
                )
            
            Circle()
                .stroke(DS.Colors.glassStroke, lineWidth: DS.Sizes.hairline)
            
            Text(icon)
                .scaledFont(size: 11, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .frame(width: DS.Sizes.glassIconSize, height: DS.Sizes.glassIconSize)
    }
}

struct GlassStemView: View {
    let height: CGFloat
    var accentColor: Color? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous)
            .fill(stemGradient)
            .frame(width: DS.Sizes.glassStemWidth, height: height)
    }
    
    private var stemGradient: LinearGradient {
        if let accentColor {
            return LinearGradient(
                colors: [
                    accentColor.opacity(0.6),
                    accentColor.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        return LinearGradient(
            colors: [
                DS.Colors.glassLineStart,
                DS.Colors.glassLineEnd
            ],
            startPoint: .top,
            endPoint: .bottom
        )
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
