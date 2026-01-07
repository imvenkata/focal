import SwiftUI

// MARK: - Design System
enum DS {
    // MARK: - Colors
    enum Colors {
        static let coral = Color(hex: "#E8847C")
        static let coralDark = Color(hex: "#D66B63")
        static let coralLight = Color(hex: "#FDF2F1")
        static let sage = Color(hex: "#7BAE7F")
        static let sageLight = Color(hex: "#F2F7F2")
        static let sky = Color(hex: "#6BA3D6")
        static let skyLight = Color(hex: "#F0F6FB")
        static let lavender = Color(hex: "#9B8EC2")
        static let lavenderLight = Color(hex: "#F5F3F9")
        static let amber = Color(hex: "#D4A853")
        static let amberLight = Color(hex: "#FBF7EE")
        static let rose = Color(hex: "#C97B8E")
        static let roseLight = Color(hex: "#FAF1F3")
        static let slate = Color(hex: "#64748B")
        static let slateLight = Color(hex: "#F4F5F7")
        static let night = Color(hex: "#5C6B7A")
        static let nightLight = Color(hex: "#F3F4F5")
        static let stone900 = Color(hex: "#1C1917")
        static let stone800 = Color(hex: "#292524")
        static let stone700 = Color(hex: "#44403C")
        static let stone500 = Color(hex: "#78716C")
        static let stone400 = Color(hex: "#A8A29E")
        static let stone300 = Color(hex: "#D6D3D1")
        static let stone200 = Color(hex: "#E7E5E4")
        static let stone100 = Color(hex: "#F5F5F4")
        static let stone50 = Color(hex: "#FAFAF9")
        static let amber100 = Color(hex: "#FEF3C7")
        static let amber600 = Color(hex: "#D97706")
        static let emerald500 = Color(hex: "#10B981")
        static let teal500 = Color(hex: "#14B8A6")
        static let danger = Color(hex: "#EF4444")
        static let dangerLight = Color(hex: "#FEF2F2")
        static let glassFillStrong = DS.Colors.stone900.opacity(0.48)
        static let glassFill = DS.Colors.stone900.opacity(0.36)
        static let glassFillLight = DS.Colors.stone900.opacity(0.28)
        static let glassStroke = DS.Colors.stone700.opacity(0.7)
        static let glassHighlight = Color.white.opacity(0.24)
        static let glassCurveHighlight = Color.white.opacity(0.12)
        static let glassLineStart = DS.Colors.stone400.opacity(0.9)
        static let glassLineEnd = DS.Colors.stone300.opacity(0.7)
        static let glassShadow = Color.black.opacity(0.28)
        static let glassTextPrimary = Color.white
        static let glassTextSecondary = Color.white.opacity(0.78)

        static let plannerBackground = Color(hex: "#0D0D0D")
        static let plannerSurface = Color(hex: "#1A1A1A")
        static let plannerSurfaceTertiary = Color(hex: "#2A2A2A")
        static let plannerSurfaceElevated = Color(hex: "#333333")
        static let plannerTextPrimary = Color(hex: "#FFFFFF")
        static let plannerTextSecondary = Color(hex: "#FFFFFF").opacity(0.6)
        static let plannerTextMuted = Color(hex: "#FFFFFF").opacity(0.4)
        static let plannerDivider = Color(hex: "#FFFFFF").opacity(0.08)
        static let plannerBlue = Color(hex: "#5B9BD5")

        static let background = Color("Background")
        static let cardBackground = Color("CardBackground")
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let divider = Color("Divider")
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let pill: CGFloat = 100
    }

    // MARK: - Sizes
    enum Sizes {
        static let iconButtonSize: CGFloat = 40
        static let taskPillDefault: CGFloat = 56
        static let taskPillLarge: CGFloat = 80
        static let taskPillSmall: CGFloat = 40
        static let fabSize: CGFloat = 56
        static let bottomNavHeight: CGFloat = 83
        static let sheetHandle: CGFloat = 36
        static let minTouchTarget: CGFloat = 44
        static let timeLabelWidth: CGFloat = 40
        static let weekTimelineHeight: CGFloat = 320
        static let hairline: CGFloat = 1
        static let glassCapsuleWidth: CGFloat = 34
        static let glassCapsuleHeight: CGFloat = 48
        static let glassIconSize: CGFloat = 16
        static let glassStemWidth: CGFloat = 1.2
    }

    // MARK: - Animation
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let quick = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)
        static let gentle = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.85)
        static let bounce = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }

    // MARK: - Typography (Apple HIG Standard)
    enum Typography {
        // Display Sizes
        static func largeTitle() -> Font { .largeTitle.weight(.bold) }
        static func title() -> Font { .title }
        static func title2() -> Font { .title2.weight(.bold) }
        static func title2(weight: Font.Weight) -> Font { .title2.weight(weight) }
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
        
        // Custom weights for emphasis
        static func title(weight: Font.Weight) -> Font { 
            .title.weight(weight) 
        }
        static func headline(weight: Font.Weight) -> Font { 
            .headline.weight(weight) 
        }
        static func body(weight: Font.Weight) -> Font { 
            .body.weight(weight) 
        }
    }

    // MARK: - Shadows
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
    func cardStyle() -> some View {
        self
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    func elevatedStyle() -> some View {
        self
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
    }
}
