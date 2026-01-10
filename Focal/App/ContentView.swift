import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var taskStore = TaskStore()
    @State private var dragState = TaskDragState()
    @State private var selectedTab: Tab = .planner
    @State private var showAddTask = false

    var body: some View {
        let showsBottomFab = !(selectedTab == .planner && taskStore.viewMode == .day)

        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .inbox:
                    InboxView()
                case .planner:
                    PlannerView()
                        .environment(taskStore)
                        .environment(dragState)
                case .insights:
                    InsightsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom navigation
            BottomTabBar(selectedTab: $selectedTab, onAddTapped: {
                showAddTask = true
            }, showsFAB: showsBottomFab)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTask) {
            PlannerTaskCreationSheet()
                .environment(taskStore)
        }
        .onAppear {
            taskStore.setModelContext(modelContext)
        }
    }
}

// MARK: - Placeholder Views
struct InboxView: View {
    var body: some View {
        VStack {
            Text("Inbox")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Colors.background)
    }
}

struct InsightsView: View {
    var body: some View {
        VStack {
            Text("Insights")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Colors.background)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Colors.background)
    }
}

#Preview {
    ContentView()
}
