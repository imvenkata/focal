import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case inbox
    case planner
    case insights
    case settings

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .planner: return "calendar"
        case .insights: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .inbox: return "Inbox"
        case .planner: return "Planner"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }
}
