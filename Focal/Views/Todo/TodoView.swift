import SwiftUI
import SwiftData

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TodoStore.self) private var todoStore

    @State private var quickAddText = ""
    @FocusState private var isQuickAddFocused: Bool
    @State private var showingAddSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Tiimo-style Header
                    headerSection

                    // Title
                    Text("To-do")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(DS.Colors.textPrimary)
                        .tracking(-0.5)

                    // Priority sections
                    prioritySections

                    // Quick add bar
                    quickAddSection
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.xl)
                .padding(.bottom, 120) // Space for tab bar
            }
            .background(DS.Colors.background)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            // Progress badge
            HStack(spacing: DS.Spacing.xs) {
                Text("🌿")
                    .font(.system(size: 16))

                Text("\(todoStore.completedTodos.count) / \(todoStore.todos.count)")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textPrimary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill))
            .shadowResting()

            Spacer()

            // Add button
            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DS.Colors.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(DS.Colors.surfacePrimary)
                    .clipShape(Circle())
                    .shadowResting()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        TodoQuickAddBar(
            text: $quickAddText,
            onAdd: addQuickTodo,
            isFocused: $isQuickAddFocused
        )
    }

    // MARK: - Priority Sections

    private var prioritySections: some View {
        VStack(spacing: DS.Spacing.xl) {
            // High priority
            TodoPrioritySection(
                priority: .high,
                todos: todoStore.highPriorityTodos,
                isCollapsed: todoStore.isSectionCollapsed(.high),
                onToggleCollapse: { todoStore.toggleSectionCollapse(.high) },
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onAddTapped: { showingAddSheet = true }
            )

            // Medium priority
            TodoPrioritySection(
                priority: .medium,
                todos: todoStore.mediumPriorityTodos,
                isCollapsed: todoStore.isSectionCollapsed(.medium),
                onToggleCollapse: { todoStore.toggleSectionCollapse(.medium) },
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onAddTapped: { showingAddSheet = true }
            )

            // Low priority
            TodoPrioritySection(
                priority: .low,
                todos: todoStore.lowPriorityTodos,
                isCollapsed: todoStore.isSectionCollapsed(.low),
                onToggleCollapse: { todoStore.toggleSectionCollapse(.low) },
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onAddTapped: { showingAddSheet = true }
            )
        }
    }

    // MARK: - Actions

    private func addQuickTodo() {
        guard !quickAddText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newTodo = TodoItem(
            title: quickAddText,
            icon: "📝",
            colorName: "sky",
            priority: .medium
        )

        withAnimation(DS.Animation.spring) {
            todoStore.addTodo(newTodo)
        }

        quickAddText = ""
        isQuickAddFocused = false
    }
}

/*
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self,
        configurations: config
    )

    let store = TodoStore(modelContext: container.mainContext)
    store.loadSampleData()

    TodoView()
        .environment(store)
        .modelContainer(container)
}
*/
