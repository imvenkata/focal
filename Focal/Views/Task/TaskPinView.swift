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

                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear,
                                Color.black.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size, height: size)

                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(task.color.color.saturated(by: 1.2), lineWidth: 1.5)
                    .frame(width: size, height: size)

                Text(task.icon)
                    .scaledFont(size: size * 0.5, relativeTo: .title3)
            }
            .shadow(color: task.color.color.opacity(0.45), radius: 10, y: 5)
            .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
            .opacity(task.isCompleted ? 0.65 : 1)
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
    var overrideTime: String? = nil

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            LiquidGlassCapsuleView(
                title: task.title,
                time: overrideTime ?? task.startTimeFormatted,
                icon: task.icon,
                accentColor: task.color.color,
                sizeScale: capsuleScale
            )
            .opacity(task.isCompleted ? 0.75 : 1)

            if task.duration > 1800 { // > 0.5 hours
                GlassStemView(height: durationStemHeight, accentColor: task.color.color)
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
                .fill(DS.Colors.surfacePrimary)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            accentTint.opacity(0.26),
                            accentTint.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            DS.Colors.glassHighlight,
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            DS.Colors.glassHighlight.opacity(0.8),
                            accentTint.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: DS.Sizes.hairline
                )

            Capsule()
                .stroke(accentTint.opacity(0.28), lineWidth: DS.Sizes.hairline)
        }
        .frame(width: capsuleWidth, height: capsuleHeight)
        .shadow(color: accentTint.opacity(0.2), radius: 10, y: 5)
        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
        .overlay(content)
    }
    
    private var content: some View {
        VStack(spacing: DS.Spacing.xs * 0.6) {
            GlassIconPip(
                icon: icon,
                accentColor: accentColor,
                size: iconSize,
                iconSize: iconFontSize
            )

            Text(time)
                .scaledFont(size: timeFontSize, weight: .semibold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textPrimary.opacity(0.8))
        }
        .padding(.vertical, contentVerticalPadding)
        .padding(.horizontal, contentHorizontalPadding)
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
        9 * sizeScale
    }

    private var iconFontSize: CGFloat {
        12 * sizeScale
    }
    
    private var contentVerticalPadding: CGFloat {
        DS.Spacing.xs * 0.5 * sizeScale
    }
    
    private var contentHorizontalPadding: CGFloat {
        DS.Spacing.xs * 0.6 * sizeScale
    }

    private var accentTint: Color {
        accentColor.saturated(by: 0.65)
    }
}

struct GlassIconPip: View {
    let icon: String
    let accentColor: Color
    var size: CGFloat = DS.Sizes.glassIconSize
    var iconSize: CGFloat = 13

    var body: some View {
        ZStack {
            Circle()
                .fill(DS.Colors.surfacePrimary)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [DS.Colors.surfaceSecondary, DS.Colors.surfacePrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accentTint.opacity(0.4), DS.Colors.borderSubtle],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: DS.Sizes.hairline
                )

            Text(icon)
                .scaledFont(size: iconSize, weight: .semibold, relativeTo: .caption)
        }
        .frame(width: size, height: size)
        .shadow(color: accentTint.opacity(0.12), radius: 4, y: 2)
    }

    private var accentTint: Color {
        accentColor.saturated(by: 0.7)
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
            return accentColor.opacity(0.2)
        }

        return DS.Colors.glassLineStart.opacity(0.2)
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
    .background(DS.Colors.bgPrimary)
}
