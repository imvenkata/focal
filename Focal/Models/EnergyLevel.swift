import Foundation

enum EnergyLevel: Int, CaseIterable, Identifiable {
    case restful = 0
    case light = 1
    case moderate = 2
    case high = 3
    case intense = 4

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .restful: return "🌿"
        case .light: return "◎"
        case .moderate: return "🔥"
        case .high: return "🔥🔥"
        case .intense: return "🔥🔥🔥"
        }
    }

    var label: String {
        switch self {
        case .restful: return "Restful"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .intense: return "Intense"
        }
    }

    var description: String {
        switch self {
        case .restful: return "Low effort, recovery activities"
        case .light: return "Easy tasks, minimal focus required"
        case .moderate: return "Regular effort, standard tasks"
        case .high: return "Demanding, requires full attention"
        case .intense: return "Maximum effort, peak performance"
        }
    }
}
