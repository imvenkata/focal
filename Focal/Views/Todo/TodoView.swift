import SwiftUI
import SwiftData

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TodoStore.self) private var todoStore

    @State private var quickAddText = ""
    @FocusState private var isQuickAddFocused: Bool
    @State private var dragTargetPriority: TodoPriority?
    @State private var draggedTodoId: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                // Tiimo-style Header
                headerSection

                // Title
                Text("To-do")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(DS.Colors.textPrimary)
                    .tracking(-0.5)

                // Priority sections (4 categories)
                prioritySections

                // Quick add bar at bottom
                quickAddSection
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.top, DS.Spacing.xl)
            .padding(.bottom, 120) // Space for tab bar
        }
        .background(DS.Colors.background)
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
        }
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        TodoQuickAddBar(
            text: $quickAddText,
            onAdd: { addTodo(with: .none) },
            isFocused: $isQuickAddFocused
        )
    }

    // MARK: - Priority Sections

    private var prioritySections: some View {
        VStack(spacing: DS.Spacing.xl) {
            // High priority
            prioritySection(for: .high, todos: todoStore.highPriorityTodos)

            // Medium priority
            prioritySection(for: .medium, todos: todoStore.mediumPriorityTodos)

            // Low priority
            prioritySection(for: .low, todos: todoStore.lowPriorityTodos)

            // Unprioritized "To-do" section
            prioritySection(for: .none, todos: todoStore.unprioritizedTodos)
        }
    }

    private func prioritySection(for priority: TodoPriority, todos: [TodoItem]) -> some View {
        TodoPrioritySection(
            priority: priority,
            todos: todos,
            isCollapsed: todoStore.isSectionCollapsed(priority),
            isDropTarget: dragTargetPriority == priority,
            onToggleCollapse: { todoStore.toggleSectionCollapse(priority) },
            onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
            onAddItem: { addTodo(title: $0, priority: priority) },
            onDropItem: { moveTodo($0, to: priority) }
        )
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first,
                  let uuid = UUID(uuidString: idString),
                  let todo = todoStore.todos.first(where: { $0.id == uuid }) else {
                return false
            }

            withAnimation(DS.Animation.spring) {
                moveTodo(todo, to: priority)
            }
            return true
        } isTargeted: { isTargeted in
            withAnimation(DS.Animation.quick) {
                dragTargetPriority = isTargeted ? priority : nil
            }
        }
    }

    // MARK: - Actions

    private func addTodo(with priority: TodoPriority) {
        guard !quickAddText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        addTodo(title: quickAddText, priority: priority)
        quickAddText = ""
        isQuickAddFocused = false
    }

    private func addTodo(title: String, priority: TodoPriority) {
        let newTodo = TodoItem(
            title: title,
            icon: "📝",
            colorName: priority == .none ? "slate" : "sky",
            priority: priority
        )

        withAnimation(DS.Animation.spring) {
            todoStore.addTodo(newTodo)
        }
    }

    private func moveTodo(_ todo: TodoItem, to priority: TodoPriority) {
        todoStore.updatePriority(for: todo, to: priority)
        HapticManager.shared.notification(.success)
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
