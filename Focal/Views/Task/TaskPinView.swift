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
                accentColor: task.color.color,
                sizeScale: capsuleScale
            )
            .opacity(task.isCompleted ? 0.6 : 1)
            
            if task.duration > 1800 { // > 0.5 hours
                GlassStemView(height: durationStemHeight, accentColor: task.color.color)
                    .opacity(task.isPast ? 0.35 : 0.7)
            }
        }
        .accessibilityLabel("\(task.title), \(task.startTimeFormatted)")
    }

    private var capsuleScale: CGFloat {
        isSunMarker ? 0.82 : 1
    }

    private var capsuleHeight: CGFloat {
        DS.Sizes.glassCapsuleHeight * capsuleScale
    }
    
    private var durationStemHeight: CGFloat {
        let durationInHours = task.duration / 3600.0
        let totalHeight = CGFloat(durationInHours) * hourHeight
        let reservedHeight = capsuleHeight + (DS.Spacing.xs * capsuleScale)
        return max(totalHeight - reservedHeight, DS.Spacing.sm)
    }

    private var isSunMarker: Bool {
        let lowerTitle = task.title.lowercased()
        return task.icon.contains("☀️") ||
            task.icon.contains("🌙") ||
            task.icon.contains("🌅") ||
            task.icon.contains("🌇") ||
            lowerTitle.contains("sunrise") ||
            lowerTitle.contains("sunset")
    }
}

// MARK: - Liquid Glass Capsule
struct LiquidGlassCapsuleView: View {
    let title: String
    let time: String
    let icon: String
    let accentColor: Color
    var sizeScale: CGFloat = 1
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(accentColor.opacity(0.2))
            
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                
                Capsule()
                    .fill(DS.Colors.glassFillStrong)
                
                Capsule()
                    .fill(accentColor.opacity(0.25))
                
                Capsule()
                    .stroke(accentColor.opacity(0.6), lineWidth: DS.Sizes.hairline)
            }
            .overlay(alignment: .top) {
                topEdgeHighlight
            }
            .overlay(alignment: .top) {
                innerCurveHighlight
            }
            .clipShape(Capsule())
            .shadow(color: DS.Colors.glassShadow, radius: 12, y: 4)
            .shadow(color: accentColor.opacity(0.25), radius: 16, y: 8)
        }
        .frame(width: capsuleWidth, height: capsuleHeight)
        .overlay(content)
    }
    
    private var content: some View {
        VStack(spacing: DS.Spacing.xs) {
            GlassIconPip(
                icon: icon,
                accentColor: accentColor,
                size: iconSize,
                iconSize: iconFontSize
            )
            
            VStack(spacing: DS.Spacing.xs) {
                Text(time)
                    .scaledFont(size: timeFontSize, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.glassTextSecondary)
                    .tracking(0.2 * sizeScale)
                
                Text(title)
                    .scaledFont(size: titleFontSize, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.glassTextPrimary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, contentVerticalPadding)
        .padding(.horizontal, contentHorizontalPadding)
    }
    
    private var topEdgeHighlight: some View {
        Rectangle()
            .fill(DS.Colors.glassHighlight)
            .frame(height: DS.Sizes.hairline)
            .padding(.horizontal, topEdgeInset)
            .padding(.top, contentVerticalPadding)
    }
    
    private var innerCurveHighlight: some View {
        RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
            .fill(DS.Colors.glassCurveHighlight)
            .frame(height: iconSize)
            .padding(.horizontal, contentHorizontalPadding)
            .padding(.top, contentVerticalPadding)
    }
    
    private var capsuleWidth: CGFloat {
        DS.Sizes.glassCapsuleWidth * sizeScale
    }
    
    private var capsuleHeight: CGFloat {
        DS.Sizes.glassCapsuleHeight * sizeScale
    }
    
    private var iconSize: CGFloat {
        DS.Sizes.glassIconSize * sizeScale
    }
    
    private var timeFontSize: CGFloat {
        8 * sizeScale
    }
    
    private var titleFontSize: CGFloat {
        9 * sizeScale
    }
    
    private var iconFontSize: CGFloat {
        11 * sizeScale
    }
    
    private var contentVerticalPadding: CGFloat {
        DS.Spacing.xs * sizeScale
    }
    
    private var contentHorizontalPadding: CGFloat {
        DS.Spacing.xs * sizeScale
    }
    
    private var topEdgeInset: CGFloat {
        DS.Spacing.sm * sizeScale
    }
}

struct GlassIconPip: View {
    let icon: String
    let accentColor: Color
    var size: CGFloat = DS.Sizes.glassIconSize
    var iconSize: CGFloat = 11
    
    var body: some View {
        ZStack {
            Circle()
                .fill(DS.Colors.glassFillLight)
            
            Circle()
                .fill(accentColor.opacity(0.3))
            
            Circle()
                .stroke(accentColor.opacity(0.6), lineWidth: DS.Sizes.hairline)

            Circle()
                .fill(DS.Colors.glassHighlight)
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(y: -size * 0.2)
            
            Text(icon)
                .scaledFont(size: iconSize, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.glassTextPrimary)
        }
        .frame(width: size, height: size)
        .shadow(color: accentColor.opacity(0.22), radius: 6, y: 3)
    }
}

struct GlassStemView: View {
    let height: CGFloat
    var accentColor: Color? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous)
            .fill(stemColor)
            .frame(width: DS.Sizes.glassStemWidth, height: height)
    }
    
    private var stemColor: Color {
        if let accentColor {
            return accentColor.opacity(0.7)
        }
        
        return DS.Colors.glassLineStart
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
