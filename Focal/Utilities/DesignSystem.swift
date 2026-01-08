import SwiftUI

// MARK: - Design System
// Style: 60% Structured (clarity) / 40% Tiimo (warmth)
// Philosophy: Calm, not clinical. Friendly, not childish. Minimal, not sterile.

enum DS {
    // MARK: - Colors
    enum Colors {
        // Brand Colors - Primary
        static let coral = Color(hex: "#E8847C")
        static let coralLight = Color(hex: "#FDF2F1")
        static let coralDark = Color(hex: "#D66B63")

        static let sage = Color(hex: "#7BAE7F")
        static let sageLight = Color(hex: "#F2F7F2")
        static let sageDark = Color(hex: "#5C8D60")

        static let sky = Color(hex: "#6BA3D6")
        static let skyLight = Color(hex: "#F0F6FB")
        static let skyDark = Color(hex: "#4A8BC7")

        static let lavender = Color(hex: "#9B8EC2")
        static let lavenderLight = Color(hex: "#F5F3F9")
        static let lavenderDark = Color(hex: "#7A6BA8")

        static let amber = Color(hex: "#D4A853")
        static let amberLight = Color(hex: "#FBF7EE")
        static let amberDark = Color(hex: "#B8923F")

        static let rose = Color(hex: "#C97B8E")
        static let roseLight = Color(hex: "#FAF1F3")
        static let roseDark = Color(hex: "#A85D71")

        static let slate = Color(hex: "#64748B")
        static let slateLight = Color(hex: "#F4F5F7")
        static let slateDark = Color(hex: "#475569")

        static let night = Color(hex: "#5C6B7A")
        static let nightLight = Color(hex: "#F3F4F5")
        static let nightDark = Color(hex: "#3F4D5A")

        // Neutral Scale (Stone)
        static let stone50 = Color(hex: "#FAFAF9")
        static let stone100 = Color(hex: "#F5F5F4")
        static let stone200 = Color(hex: "#E7E5E4")
        static let stone300 = Color(hex: "#D6D3D1")
        static let stone400 = Color(hex: "#A8A29E")
        static let stone500 = Color(hex: "#78716C")
        static let stone700 = Color(hex: "#44403C")
        static let stone800 = Color(hex: "#292524")
        static let stone900 = Color(hex: "#1C1917")

        // Semantic - Background
        static let background = Color("Background")
        static let cardBackground = Color("CardBackground")
        static let bgPrimary = background
        static let bgSecondary = cardBackground
        static let bgTertiary = stone100
        static let bgElevated = Color.white

        // Semantic - Text
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textMuted = stone400
        static let textInverse = Color.white

        // Semantic - Border
        static let border = stone200
        static let borderFocused = stone500
        static let divider = Color("Divider")
        static let dividerStrong = stone300

        // Status Colors
        static let success = Color(hex: "#10B981")
        static let successLight = Color(hex: "#ECFDF5")
        static let warning = Color(hex: "#F59E0B")
        static let warningLight = Color(hex: "#FFFBEB")
        static let danger = Color(hex: "#EF4444")
        static let dangerLight = Color(hex: "#FEF2F2")
        static let info = sky
        static let infoLight = skyLight

        // Utility Colors
        static let emerald500 = Color(hex: "#10B981")
        static let teal500 = Color(hex: "#14B8A6")
        static let amber100 = Color(hex: "#FEF3C7")
        static let amber600 = Color(hex: "#D97706")

        // Planner (Dark Mode)
        static let plannerBackground = Color(hex: "#0D0D0D")
        static let plannerSurface = Color(hex: "#1A1A1A")
        static let plannerSurfaceTertiary = Color(hex: "#2A2A2A")
        static let plannerSurfaceElevated = Color(hex: "#333333")
        static let plannerTextPrimary = Color(hex: "#FFFFFF")
        static let plannerTextSecondary = Color(hex: "#FFFFFF").opacity(0.6)
        static let plannerTextMuted = Color(hex: "#FFFFFF").opacity(0.4)
        static let plannerDivider = Color(hex: "#FFFFFF").opacity(0.08)
        static let plannerBlue = Color(hex: "#5B9BD5")

        // Glass Effect
        static let glassFillStrong = stone900.opacity(0.48)
        static let glassFill = stone900.opacity(0.36)
        static let glassFillLight = stone900.opacity(0.28)
        static let glassStroke = stone700.opacity(0.7)
        static let glassHighlight = Color.white.opacity(0.24)
        static let glassCurveHighlight = Color.white.opacity(0.12)
        static let glassLineStart = stone400.opacity(0.9)
        static let glassLineEnd = stone300.opacity(0.7)
        static let glassShadow = Color.black.opacity(0.28)
        static let glassTextPrimary = Color.white
        static let glassTextSecondary = Color.white.opacity(0.78)
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
        static let timeLabelWidth: CGFloat = 40
        static let weekTimelineHeight: CGFloat = 320

        // Glass components
        static let glassCapsuleWidth: CGFloat = 34
        static let glassCapsuleHeight: CGFloat = 48
        static let glassIconSize: CGFloat = 16
        static let glassStemWidth: CGFloat = 1.2

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
            case .small: return 44
            case .medium: return 56
            case .large: return 72
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
            case .small: return 16
            case .medium: return 20
            case .large: return 24
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
            case .dragged: return 1.15
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
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    func elevatedStyle() -> some View {
        self
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
    }

    // Shadow Helpers
    func shadowRaised() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    func shadowElevated() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    func shadowFloating() -> some View {
        self.shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
    }

    func shadowColored(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.45), radius: 8, x: 0, y: 4)
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
                            colors: [.clear, Color.white.opacity(0.4), .clear],
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
                    .fill(DS.Colors.stone100)
                    .frame(width: DS.Sizes.closeButtonSize, height: DS.Sizes.closeButtonSize)

                Circle()
                    .stroke(DS.Colors.stone200, lineWidth: 1)
                    .frame(width: DS.Sizes.closeButtonSize, height: DS.Sizes.closeButtonSize)

                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Colors.stone500)
            }
            .shadowRaised()
        }
        .buttonStyle(PressableStyle(scaleAmount: 0.9))
        .accessibilityLabel("Close")
    }
}
