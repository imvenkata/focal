import SwiftUI

enum TaskColor: String, CaseIterable, Codable, Identifiable {
    case coral
    case sage
    case sky
    case lavender
    case amber
    case rose
    case slate
    case night

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .coral: return DS.Colors.coral
        case .sage: return DS.Colors.sage
        case .sky: return DS.Colors.sky
        case .lavender: return DS.Colors.lavender
        case .amber: return DS.Colors.amber
        case .rose: return DS.Colors.rose
        case .slate: return DS.Colors.slate
        case .night: return DS.Colors.night
        }
    }

    var lightColor: Color {
        switch self {
        case .coral: return DS.Colors.coralLight
        case .sage: return DS.Colors.sageLight
        case .sky: return DS.Colors.skyLight
        case .lavender: return DS.Colors.lavenderLight
        case .amber: return DS.Colors.amberLight
        case .rose: return DS.Colors.roseLight
        case .slate: return DS.Colors.slateLight
        case .night: return DS.Colors.nightLight
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
