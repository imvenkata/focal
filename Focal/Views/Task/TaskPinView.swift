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
                                DS.Colors.textInverse.opacity(0.25),
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
            .shadowColored(task.color.color)
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

    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 2) {
            LiquidGlassCapsuleView(
                title: task.title,
                time: overrideTime ?? compactTime,
                icon: task.icon,
                accentColor: task.color.color,
                sizeScale: capsuleScale,
                showTitlePreview: isPressed,
                isCurrentTask: isCurrentTask,
                isUpcoming: isUpcoming
            )
            .opacity(task.isCompleted ? 0.6 : 1)
            .scaleEffect(pulseScale)
            .overlay {
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: -4)
                }
            }

            if task.duration > 1800 { // > 0.5 hours
                GlassStemView(height: durationStemHeight, accentColor: task.color.color)
            }
        }
        .onLongPressGesture(minimumDuration: 0.15, pressing: { pressing in
            withAnimation(DS.Animation.quick) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            if isUpcoming {
                startPulseAnimation()
            }
        }
        .accessibilityLabel("\(task.title), \(task.startTimeFormatted)")
    }

    /// Task is currently active (happening now)
    private var isCurrentTask: Bool {
        task.isActive
    }

    /// Task starts within the next 15 minutes
    private var isUpcoming: Bool {
        guard !task.isCompleted else { return false }
        let now = Date()
        let fifteenMinutesFromNow = now.addingTimeInterval(15 * 60)
        return task.startTime > now && task.startTime <= fifteenMinutesFromNow
    }

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }
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

    private var compactTime: String {
        let hour = task.startTime.hour
        let minute = task.startTime.minute
        let hourDisplay = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let ampm = hour < 12 ? "a" : "p"
        if minute == 0 {
            return "\(hourDisplay)\(ampm)"
        } else {
            return "\(hourDisplay):\(String(format: "%02d", minute))"
        }
    }
}

// MARK: - Premium Task Capsule (Structured-style)
struct LiquidGlassCapsuleView: View {
    let title: String
    let time: String
    let icon: String
    let accentColor: Color
    var sizeScale: CGFloat = 1
    var showTitlePreview: Bool = false
    var isCurrentTask: Bool = false
    var isUpcoming: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Icon circle at top
            ZStack {
                // Glow effect for current task
                if isCurrentTask {
                    Circle()
                        .fill(accentColor.opacity(0.3))
                        .frame(width: iconSize + 8, height: iconSize + 8)
                        .blur(radius: 4)
                }

                Circle()
                    .fill(accentColor)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                Text(icon)
                    .font(.system(size: iconFontSize))
            }
            .frame(width: iconSize, height: iconSize)
            .shadow(color: accentColor.opacity(isCurrentTask ? 0.6 : 0.4), radius: isCurrentTask ? 8 : 4, y: 2)

            // Time label or title preview
            if showTitlePreview {
                Text(titlePreview)
                    .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)
                    .padding(.top, 3)
                    .transition(.opacity)
            } else {
                Text(time)
                    .font(.system(size: timeFontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Colors.textSecondary)
                    .padding(.top, 3)
            }
        }
        .frame(width: capsuleWidth, height: capsuleHeight)
        .overlay(alignment: .top) {
            // Upcoming indicator dot
            if isUpcoming {
                Circle()
                    .fill(DS.Colors.warning)
                    .frame(width: 6, height: 6)
                    .offset(x: iconSize / 2 - 2, y: 2)
            }
        }
    }

    /// First 3 characters of the title
    private var titlePreview: String {
        String(title.prefix(3)).uppercased()
    }

    private var capsuleWidth: CGFloat {
        DS.Sizes.glassCapsuleWidth * sizeScale
    }

    private var capsuleHeight: CGFloat {
        DS.Sizes.glassCapsuleHeight * sizeScale
    }

    private var iconSize: CGFloat {
        (DS.Sizes.glassIconSize + 8) * sizeScale
    }

    private var timeFontSize: CGFloat {
        10 * sizeScale
    }

    private var iconFontSize: CGFloat {
        18 * sizeScale
    }
}

struct GlassIconPip: View {
    let icon: String
    let accentColor: Color
    var size: CGFloat = DS.Sizes.glassIconSize + 4
    var iconSize: CGFloat = 18

    var body: some View {
        ZStack {
            Circle()
                .fill(accentColor)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            Text(icon)
                .font(.system(size: iconSize))
        }
        .frame(width: size, height: size)
        .shadow(color: accentColor.opacity(0.35), radius: 3, y: 2)
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

    private var stemGradient: some ShapeStyle {
        if let accentColor {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [accentColor.opacity(0.5), accentColor.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        return AnyShapeStyle(DS.Colors.borderSubtle.opacity(0.4))
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
