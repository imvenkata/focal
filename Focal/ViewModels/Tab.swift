import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case inbox
    case planner
    case todos
    case insights
    case settings

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .planner: return "calendar"
        case .todos: return "checklist"
        case .insights: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .inbox: return "Inbox"
        case .planner: return "Planner"
        case .todos: return "Todos"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }
}
