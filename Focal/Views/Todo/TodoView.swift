import SwiftUI

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
                    // Header
                    headerSection

                    // Quick add bar
                    quickAddSection

                    // Priority sections
                    prioritySections
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.xl)
                .padding(.bottom, 120) // Space for tab bar
            }
            .background(DS.Colors.background)

            // Bottom quick add (sticky)
            bottomQuickAdd
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Title
            Text("Todos")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DS.Colors.textPrimary)

            // Progress stats
            if !todoStore.todos.isEmpty {
                HStack(spacing: DS.Spacing.md) {
                    Text("\(todoStore.completedTodos.count) of \(todoStore.todos.count) completed")
                        .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
                        .foregroundStyle(DS.Colors.textSecondary)

                    Spacer()

                    // Collapse all button
                    if !todoStore.expandedTodoIds.isEmpty {
                        Button(action: {
                            withAnimation(DS.Animation.spring) {
                                todoStore.collapseAll()
                            }
                        }) {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: "chevron.up.circle.fill")
                                Text("Collapse All")
                            }
                            .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.sky)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quick Add Section (Top)

    private var quickAddSection: some View {
        TodoQuickAddBar(
            text: $quickAddText,
            onAdd: addQuickTodo,
            isFocused: $isQuickAddFocused
        )
    }

    // MARK: - Priority Sections

    private var prioritySections: some View {
        VStack(spacing: DS.Spacing.xxl) {
            // High priority
            TodoPrioritySection(
                priority: .high,
                todos: todoStore.highPriorityTodos,
                expandedIds: todoStore.expandedTodoIds,
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onToggleExpand: {
                    withAnimation(DS.Animation.spring) {
                        todoStore.toggleExpanded($0.id)
                    }
                },
                onToggleSubtask: { todoStore.toggleSubtask($0, in: $1) },
                onDeleteSubtask: { todoStore.deleteSubtask($0, from: $1) },
                onAddSubtask: { todoStore.addSubtask(to: $1, title: $0) }
            )

            // Medium priority
            TodoPrioritySection(
                priority: .medium,
                todos: todoStore.mediumPriorityTodos,
                expandedIds: todoStore.expandedTodoIds,
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onToggleExpand: {
                    withAnimation(DS.Animation.spring) {
                        todoStore.toggleExpanded($0.id)
                    }
                },
                onToggleSubtask: { todoStore.toggleSubtask($0, in: $1) },
                onDeleteSubtask: { todoStore.deleteSubtask($0, from: $1) },
                onAddSubtask: { todoStore.addSubtask(to: $1, title: $0) }
            )

            // Low priority
            TodoPrioritySection(
                priority: .low,
                todos: todoStore.lowPriorityTodos,
                expandedIds: todoStore.expandedTodoIds,
                onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
                onToggleExpand: {
                    withAnimation(DS.Animation.spring) {
                        todoStore.toggleExpanded($0.id)
                    }
                },
                onToggleSubtask: { todoStore.toggleSubtask($0, in: $1) },
                onDeleteSubtask: { todoStore.deleteSubtask($0, from: $1) },
                onAddSubtask: { todoStore.addSubtask(to: $1, title: $0) }
            )
        }
    }

    // MARK: - Bottom Quick Add (Sticky)

    private var bottomQuickAdd: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [DS.Colors.background.opacity(0), DS.Colors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            // Quick add bar
            TodoQuickAddBar(
                text: $quickAddText,
                onAdd: addQuickTodo,
                isFocused: $isQuickAddFocused
            )
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, 100) // Space for tab bar
            .background(DS.Colors.background)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self,
        configurations: config
    )

    let store = TodoStore(modelContext: container.mainContext)
    store.loadSampleData()

    return TodoView()
        .environment(store)
        .modelContainer(container)
}
