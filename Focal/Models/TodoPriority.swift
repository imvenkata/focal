import Foundation

enum TodoPriority: String, CaseIterable, Codable, Identifiable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    var icon: String {
        switch self {
        case .high: return "▲"
        case .medium: return "●"
        case .low: return "▼"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    var colorName: String {
        switch self {
        case .high: return "rose"
        case .medium: return "amber"
        case .low: return "sage"
        }
    }

    var backgroundColor: String {
        switch self {
        case .high: return "#FFEBEE"
        case .medium: return "#FFF3E0"
        case .low: return "#E3F2FD"
        }
    }
}
