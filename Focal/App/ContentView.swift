import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var taskStore = TaskStore()
    @State private var todoStore = TodoStore()
    @State private var dragState = TaskDragState()
    @State private var aiCoordinator = AICoordinator()
    @State private var selectedTab: AppTab = .planner
    @State private var showAIOnboarding = false
    @State private var brainDumpSearchText = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            // Planner tab
            Tab("Planner", systemImage: "calendar", value: .planner) {
                PlannerView()
                    .environment(taskStore)
                    .environment(dragState)
                    .environment(aiCoordinator)
            }
            
            // Todos tab
            Tab("Todos", systemImage: "checklist", value: .todos) {
                TodoView()
                    .environment(todoStore)
                    .environment(taskStore)
                    .environment(aiCoordinator)
            }
            
            // Brain Dump as floating action button (uses .search role for liquid glass separation)
            Tab("Brain Dump", systemImage: "sparkles", value: .brainDump, role: .search) {
                NavigationStack {
                    BrainDumpView()
                        .environment(aiCoordinator)
                        .environment(todoStore)
                }
            }
        }
        .onAppear {
            taskStore.setModelContext(modelContext)
            todoStore.setModelContext(modelContext)
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
