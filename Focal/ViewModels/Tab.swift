import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case inbox
    case planner
    case todos
    case insights
    case settings
    case brainDump

    var id: String { rawValue }

    /// Tabs currently visible in the app (Phase 1: only Planner and Todos)
    static var visibleTabs: [AppTab] {
        [.planner, .todos, .settings]
    }

    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .planner: return "calendar"
        case .todos: return "checklist"
        case .insights: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        case .brainDump: return "sparkles"
        }
    }

    var label: String {
        switch self {
        case .inbox: return "Inbox"
        case .planner: return "Planner"
        case .todos: return "Todos"
        case .insights: return "Insights"
        case .settings: return "Settings"
        case .brainDump: return "Brain Dump"
        }
    }
}

