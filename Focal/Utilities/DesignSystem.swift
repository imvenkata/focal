import SwiftUI

// MARK: - Design System
enum DS {
    // MARK: - Colors
    enum Colors {
        static let coral = Color(hex: "#E8847C")
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
