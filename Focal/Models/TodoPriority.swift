import Foundation
import SwiftUI

enum TodoPriority: String, CaseIterable, Codable, Identifiable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case none = "NONE"  // Unprioritized "To-do" category

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .none: return "To-do"
        }
    }

    var icon: String? {
        switch self {
        case .high: return "▲"
        case .medium: return "●"
        case .low: return "▼"
        case .none: return nil  // No icon for unprioritized
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .none: return 3
        }
    }

    var colorName: String {
        switch self {
        case .high: return "rose"
        case .medium: return "amber"
        case .low: return "sage"
        case .none: return "slate"
        }
    }

    var backgroundColor: String {
        switch self {
        case .high: return "#FFEBEE"
        case .medium: return "#FFF3E0"
        case .low: return "#E3F2FD"
        case .none: return "#F5F5F5"
        }
    }

    // MARK: - Premium Badge Colors

    /// Accent color for this priority (vibrant, saturated)
    var accentColor: Color {
        switch self {
        case .high: return Color(hex: "#E53935")     // Rich red
        case .medium: return Color(hex: "#FB8C00")   // Vibrant orange
        case .low: return Color(hex: "#1E88E5")      // Bold blue
        case .none: return Color(hex: "#546E7A")     // Slate gray
        }
    }

    /// Icon color for the priority indicator
    var iconColor: Color {
        switch self {
        case .high: return Color(hex: "#C62828")     // Deep red
        case .medium: return Color(hex: "#E65100")   // Deep orange
        case .low: return Color(hex: "#1565C0")      // Deep blue
        case .none: return Color(hex: "#37474F")     // Dark slate
        }
    }

    /// Background color for section badge (rich, visible)
    var badgeBackground: Color {
        switch self {
        case .high: return Color(hex: "#FFCDD2")     // Stronger pink
        case .medium: return Color(hex: "#FFE0B2")   // Warmer orange-cream
        case .low: return Color(hex: "#BBDEFB")      // Richer blue
        case .none: return Color(hex: "#CFD8DC")     // Stronger gray
        }
    }

    /// Text color for badge label (high contrast)
    var badgeTextColor: Color {
        switch self {
        case .high: return Color(hex: "#B71C1C")     // Dark red
        case .medium: return Color(hex: "#E65100")   // Dark orange
        case .low: return Color(hex: "#0D47A1")      // Dark blue
        case .none: return Color(hex: "#263238")     // Very dark slate
        }
    }
}
