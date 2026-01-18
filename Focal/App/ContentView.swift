import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var taskStore = TaskStore()
    @State private var todoStore = TodoStore()
    @State private var dragState = TaskDragState()
    @State private var aiCoordinator = AICoordinator()
    @State private var selectedTab: AppTab = .planner
    @State private var showBrainDump = false
    @State private var showAIOnboarding = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content (Phase 1: Planner and Todos only)
            Group {
                switch selectedTab {
                case .planner:
                    PlannerView()
                        .environment(taskStore)
                        .environment(dragState)
                        .environment(aiCoordinator)
                case .todos:
                    TodoView()
                        .environment(todoStore)
                        .environment(taskStore)
                        .environment(aiCoordinator)
                case .settings:
                    AISettingsView(
                        showOnboarding: $showAIOnboarding
                    )
                    .environment(aiCoordinator)
                default:
                    // Future tabs: inbox, insights
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom navigation
            BottomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            taskStore.setModelContext(modelContext)
            todoStore.setModelContext(modelContext)
        }
        .sheet(isPresented: $showBrainDump) {
            BrainDumpView()
                .environment(aiCoordinator)
                .environment(todoStore)
        }
        .sheet(isPresented: $showAIOnboarding) {
            AIOnboardingView()
                .environment(aiCoordinator)
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
