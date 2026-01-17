import SwiftUI

// MARK: - Design System
// Style: 60% Structured (clarity) / 40% Tiimo (warmth)
// Philosophy: Calm, not clinical. Friendly, not childish. Minimal, not sterile.

enum DS {
    // MARK: - Colors
    enum Colors {
        // Brand palette (assets)
        static let coral = Color("Coral")
        static let coralLight = Color("CoralLight")
        static let coralDark = Color(hex: "#D66B63")

        static let sage = Color("Sage")
        static let sageLight = Color("SageLight")
        static let sageDark = Color(hex: "#5C8D60")

        static let sky = Color("Sky")
        static let skyLight = Color("SkyLight")
        static let skyDark = Color(hex: "#4A8BC7")

        static let lavender = Color("Lavender")
        static let lavenderLight = Color("LavenderLight")
        static let lavenderDark = Color(hex: "#7A6BA8")

        static let amber = Color("Amber")
        static let amberLight = Color("AmberLight")
        static let amberDark = Color(hex: "#B8923F")

        static let rose = Color("Rose")
        static let roseLight = Color("RoseLight")
        static let roseDark = Color(hex: "#A85D71")

        static let slate = Color("Slate")
        static let slateLight = Color("SlateLight")
        static let slateDark = Color(hex: "#475569")

        static let night = Color("Night")
        static let nightLight = Color("NightLight")
        static let nightDark = Color(hex: "#141C24")

        // Semantic - Background & Surfaces
        static let background = Color("Background")
        static let cardBackground = Color("CardBackground")
        static let bgPrimary = background
        static let bgSecondary = Color("BackgroundSecondary")
        static let surfacePrimary = cardBackground
        static let surfaceSecondary = Color("SurfaceSecondary")
        static let bgTertiary = surfaceSecondary
        static let bgElevated = surfacePrimary
        static let overlay = Color("Overlay")

        // Semantic - Text
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textTertiary = Color("TextTertiary")
        static let textMuted = textTertiary
        static let textInverse = Color("TextInverse")

        // Semantic - Border
        static let divider = Color("Divider")
        static let borderSubtle = divider
        static let borderStrong = Color("BorderStrong")
        static let border = borderSubtle
        static let borderFocused = borderStrong
        static let dividerStrong = borderStrong

        // Semantic - Actions
        static let primary = sky
        static let secondary = coral
        static let accent = sage

        // Status Colors
        static let success = sage
        static let successLight = sageLight
        static let warning = amber
        static let warningLight = amberLight
        static let error = rose
        static let danger = error
        static let dangerLight = roseLight
        static let info = sky
        static let infoLight = skyLight

        // Utility Colors (legacy mappings)
        static let emerald500 = sage
        static let teal500 = sky
        static let amber100 = amberLight
        static let amber600 = amber

        // Glass Effect
        static let glassFillStrong = overlay.opacity(0.48)
        static let glassFill = overlay.opacity(0.36)
        static let glassFillLight = overlay.opacity(0.24)
        static let glassStroke = borderStrong.opacity(0.7)
        static let glassHighlight = textInverse.opacity(0.24)
        static let glassCurveHighlight = textInverse.opacity(0.12)
        static let glassLineStart = textSecondary.opacity(0.9)
        static let glassLineEnd = textTertiary.opacity(0.7)
        static let glassShadow = overlay.opacity(0.28)
        static let glassTextPrimary = textInverse
        static let glassTextSecondary = textInverse.opacity(0.78)
    }

    // MARK: - Spacing (4pt/8pt grid)
    enum Spacing {
        static let xs: CGFloat = 4      // Icon-to-text, tight grouping
        static let sm: CGFloat = 8      // Related elements, list item padding
        static let md: CGFloat = 12     // Component internal padding
        static let lg: CGFloat = 16     // Card padding, section gaps
        static let xl: CGFloat = 20     // Screen margins, major sections
        static let xxl: CGFloat = 24    // Large component gaps
        static let xxxl: CGFloat = 32   // Screen section dividers
        static let xxxxl: CGFloat = 48  // Major layout breaks
    }

    // MARK: - Radius
    enum Radius {
        static let xs: CGFloat = 4      // Tags, small chips, progress bars
        static let sm: CGFloat = 8      // Input fields, small buttons
        static let md: CGFloat = 12     // Cards, task pills, medium buttons
        static let lg: CGFloat = 16     // Sheets, large cards, modals
        static let xl: CGFloat = 20     // Bottom sheets, large containers
        static let xxl: CGFloat = 24    // Full-screen overlays
        static let xxxl: CGFloat = 32   // Hero cards
        static let pill: CGFloat = 100  // Pills, fully rounded elements
    }

    // MARK: - Sizes
    enum Sizes {
        // Touch targets
        static let minTouchTarget: CGFloat = 44
        static let iconButtonSize: CGFloat = 40

        // Components
        static let fabSize: CGFloat = 56
        static let bottomNavHeight: CGFloat = 83
        static let sheetHandle: CGFloat = 36
        static let buttonHeight: CGFloat = 50
        static let buttonHeightSmall: CGFloat = 44
        static let closeButtonSize: CGFloat = 32
        static let checkboxSize: CGFloat = 28
        static let colorChipSize: CGFloat = 32

        // Task Pills
        static let taskPillSmall: CGFloat = 40
        static let taskPillDefault: CGFloat = 56
        static let taskPillLarge: CGFloat = 80

        // Timeline
        static let timeLabelWidth: CGFloat = 32
        static let weekTimelineHeight: CGFloat = 480  // Taller for better visibility
        static let weekColumnSpacing: CGFloat = 6

        // Glass components (week view capsules) - Tiimo-style larger sizes
        static let glassCapsuleWidth: CGFloat = 48
        static let glassCapsuleHeight: CGFloat = 56
        static let glassIconSize: CGFloat = 26
        static let glassStemWidth: CGFloat = 2

        // Misc
        static let hairline: CGFloat = 1
    }

    // MARK: - Animation
    enum Animation {
        // Spring animations (preferred)
        static let quick = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let gentle = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.85)
        static let bounce = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)

        // Non-spring alternatives
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let linear = SwiftUI.Animation.linear(duration: 0.15)

        // Reduce motion alternative
        static let reduced = SwiftUI.Animation.linear(duration: 0.1)
    }

    // MARK: - Typography
    enum Typography {
        // Display Sizes
        static func largeTitle() -> Font { .largeTitle.weight(.bold) }
        static func title() -> Font { .title.weight(.bold) }
        static func title2() -> Font { .title2.weight(.bold) }
        static func title3() -> Font { .title3.weight(.semibold) }

        // Content Sizes
        static func headline() -> Font { .headline }
        static func body() -> Font { .body }
        static func callout() -> Font { .callout }
        static func subheadline() -> Font { .subheadline }

        // Detail Sizes
        static func footnote() -> Font { .footnote }
        static func caption() -> Font { .caption }
        static func caption2() -> Font { .caption2 }

        // Weighted variants
        static func title(weight: Font.Weight) -> Font { .title.weight(weight) }
        static func title2(weight: Font.Weight) -> Font { .title2.weight(weight) }
        static func title3(weight: Font.Weight) -> Font { .title3.weight(weight) }
        static func headline(weight: Font.Weight) -> Font { .headline.weight(weight) }
        static func body(weight: Font.Weight) -> Font { .body.weight(weight) }
        static func callout(weight: Font.Weight) -> Font { .callout.weight(weight) }
    }

    // MARK: - Haptics
    enum Haptics {
        static func light() { HapticManager.shared.impact(.light) }
        static func medium() { HapticManager.shared.impact(.medium) }
        static func heavy() { HapticManager.shared.impact(.heavy) }
        static func soft() { HapticManager.shared.impact(.soft) }
        static func success() { HapticManager.shared.notification(.success) }
        static func warning() { HapticManager.shared.notification(.warning) }
        static func error() { HapticManager.shared.notification(.error) }
        static func selection() { HapticManager.shared.selection() }
    }

    // MARK: - Task Capsule Configuration

    /// Capsule size variants for different contexts
    enum CapsuleSize {
        case small   // 44pt - Widgets, compact lists
        case medium  // 56pt - Default daily view
        case large   // 72pt - Focus mode, detail cards

        var height: CGFloat {
            switch self {
            case .small: return 52
            case .medium: return 64
            case .large: return 80
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 26
            case .large: return 32
            }
        }

        var titleSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }

        var subtitleSize: CGFloat {
            switch self {
            case .small: return 11
            case .medium: return 12
            case .large: return 14
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .system(size: 14, weight: .semibold)
            case .medium: return .system(size: 16, weight: .semibold)
            case .large: return .system(size: 18, weight: .semibold)
            }
        }

        var subtitleFont: Font {
            switch self {
            case .small: return .system(size: 11, weight: .regular)
            case .medium: return .system(size: 12, weight: .regular)
            case .large: return .system(size: 14, weight: .regular)
            }
        }

        var checkboxSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 28
            }
        }

        var stripeWidth: CGFloat { 3 }
    }

    /// Visual states for task capsules
    enum CapsuleState {
        case `default`   // Standard appearance
        case pressed     // Being tapped
        case selected    // Active/highlighted (e.g., currently running task)
        case completed   // Task marked done
        case overdue     // Past due, not completed
        case dragged     // Being dragged for reordering
        case disabled    // Non-interactive
        case dimmed      // Focus mode - other tasks dimmed

        var opacity: Double {
            switch self {
            case .default, .pressed, .selected, .overdue, .dragged: return 1.0
            case .completed: return 0.55
            case .disabled: return 0.4
            case .dimmed: return 0.3
            }
        }

        var scale: CGFloat {
            switch self {
            case .pressed: return 0.97
            case .dragged: return 1.05
            default: return 1.0
            }
        }

        var brightness: Double {
            switch self {
            case .pressed: return -0.08
            default: return 0
            }
        }

        var showStrikethrough: Bool {
            self == .completed
        }

        var showCheckmark: Bool {
            self == .completed
        }

        var showWarningBadge: Bool {
            self == .overdue
        }
    }

    /// Context for capsule display
    enum CapsuleContext {
        case list       // Full-width list view
        case timeline   // Positioned in timeline
        case widget     // Compact widget display
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func saturated(by factor: CGFloat) -> Color {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return self
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        // Convert to HSB
        var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0
        UIColor(red: r, green: g, blue: b, alpha: a).getHue(&h, saturation: &s, brightness: &br, alpha: nil)

        // Increase saturation
        let newS = min(s * factor, 1.0)
        return Color(hue: h, saturation: newS, brightness: br, opacity: a)
    }
}

// MARK: - View Extensions
extension View {
    // Card Styles
    func cardStyle() -> some View {
        self
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(DS.Colors.borderSubtle, lineWidth: DS.Sizes.hairline)
            )
            .shadowResting()
    }

    func elevatedStyle() -> some View {
        self
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
            )
            .shadowLifted()
    }

    // Shadow Helpers
    func shadowResting() -> some View {
        self.shadow(color: DS.Colors.overlay.opacity(0.08), radius: 4, x: 0, y: 1)
    }

    func shadowLifted() -> some View {
        self.shadow(color: DS.Colors.overlay.opacity(0.16), radius: 12, x: 0, y: 6)
    }

    func shadowColored(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)
    }

    // Reduce Motion Support
    func adaptiveAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.modifier(AdaptiveAnimationModifier(animation: animation, value: value))
    }
}

// MARK: - Adaptive Animation Modifier
struct AdaptiveAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(
            reduceMotion ? DS.Animation.reduced : animation,
            value: value
        )
    }
}

// MARK: - Button Styles

/// Primary action button - filled with brand color
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Sizes.buttonHeight)
            .background(isEnabled ? DS.Colors.sky : DS.Colors.slate)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

/// Secondary action button - bordered
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(DS.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Sizes.buttonHeightSmall)
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

/// Ghost button - text only with hover background
struct GhostButtonStyle: ButtonStyle {
    var color: Color = DS.Colors.sky

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(color)
            .frame(height: DS.Sizes.buttonHeightSmall)
            .background(configuration.isPressed ? DS.Colors.bgTertiary : .clear)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

/// Pressable style for custom interactive elements
struct PressableStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

/// Chip/Tag selection button style
struct ChipButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .white : DS.Colors.textPrimary)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(isSelected ? DS.Colors.sky : DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Text(icon)
                .font(.system(size: 64))

            VStack(spacing: DS.Spacing.sm) {
                Text(title)
                    .font(DS.Typography.title2())
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(description)
                    .font(DS.Typography.body())
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(width: 200)
                    .padding(.top, DS.Spacing.sm)
            }
        }
        .frame(maxWidth: 280)
        .padding(DS.Spacing.xxl)
    }
}

// MARK: - Loading/Skeleton View
struct SkeletonView: View {
    var cornerRadius: CGFloat = DS.Radius.sm
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DS.Colors.divider)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.clear, DS.Colors.textInverse.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Close Button
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(DS.Colors.surfaceSecondary)
                    .frame(width: DS.Sizes.closeButtonSize, height: DS.Sizes.closeButtonSize)

                Circle()
                    .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                    .frame(width: DS.Sizes.closeButtonSize, height: DS.Sizes.closeButtonSize)

                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .shadowResting()
        }
        .buttonStyle(PressableStyle(scaleAmount: 0.9))
        .accessibilityLabel("Close")
    }
}

// MARK: - Calm Mode Messages
enum CalmMessages {
    static func greeting(for hour: Int) -> String {
        switch hour {
        case 5..<12:
            return "Good morning 🌅"
        case 12..<17:
            return "Good afternoon 🌿"
        case 17..<21:
            return "Good evening 🌙"
        default:
            return "Take it easy 🌙"
        }
    }

    static let encouragement = [
        "You've got this!",
        "One step at a time",
        "Take your time",
        "You're doing great!",
        "Small steps matter",
        "Be kind to yourself"
    ]

    static func randomEncouragement() -> String {
        encouragement.randomElement() ?? "You've got this!"
    }

    static func completed(_ count: Int) -> String {
        switch count {
        case 0:
            return "Ready to start? 🌱"
        case 1:
            return "You've completed 1 today! 🎉"
        case 2...4:
            return "You've completed \(count) today! 🎉"
        default:
            return "Amazing! \(count) completed today! 🌟"
        }
    }

    static func softDueLabel(_ todo: TodoItem) -> String {
        if todo.isDueToday {
            return "For today"
        } else if todo.isDueTomorrow {
            return "For tomorrow"
        } else if todo.isOverdue {
            return "Needs attention"
        } else if let formatted = todo.dueDateFormatted {
            return formatted
        }
        return ""
    }
}

// MARK: - User Energy State (for Calm Mode)
enum UserEnergy: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .low: return "😴"
        case .medium: return "😊"
        case .high: return "⚡"
        }
    }

    var color: Color {
        switch self {
        case .low: return DS.Colors.lavender
        case .medium: return DS.Colors.sage
        case .high: return DS.Colors.amber
        }
    }

    var description: String {
        switch self {
        case .low: return "Low energy, simple tasks"
        case .medium: return "Balanced, regular tasks"
        case .high: return "Full energy, any task"
        }
    }
}
