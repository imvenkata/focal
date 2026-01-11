import SwiftUI
import SwiftData

@Observable
final class TodoStore {
    private var modelContext: ModelContext?
    var todos: [TodoItem] = []
    var expandedTodoIds: Set<UUID> = []
    var collapsedSections: Set<TodoPriority> = []

    // MARK: - Section Collapse

    func toggleSectionCollapse(_ priority: TodoPriority) {
        if collapsedSections.contains(priority) {
            collapsedSections.remove(priority)
        } else {
            collapsedSections.insert(priority)
        }
        HapticManager.shared.selection()
    }

    func isSectionCollapsed(_ priority: TodoPriority) -> Bool {
        collapsedSections.contains(priority)
    }

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        if modelContext != nil {
            fetchTodos()
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchTodos()
    }

    private func fetchTodos() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [
                SortDescriptor(\.orderIndex),
                SortDescriptor(\.createdAt)
            ]
        )
        todos = (try? modelContext.fetch(descriptor)) ?? []
    }

    func save() {
        try? modelContext?.save()
    }

    // MARK: - Computed Properties

    var todosByPriority: [TodoPriority: [TodoItem]] {
        Dictionary(grouping: todos) { $0.priorityEnum }
    }

    var highPriorityTodos: [TodoItem] {
        todos.filter { $0.priorityEnum == .high && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var mediumPriorityTodos: [TodoItem] {
        todos.filter { $0.priorityEnum == .medium && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var lowPriorityTodos: [TodoItem] {
        todos.filter { $0.priorityEnum == .low && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var unprioritizedTodos: [TodoItem] {
        todos.filter { $0.priorityEnum == .none && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }

    var activeTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }

    var completionProgress: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedTodos.count) / Double(todos.count)
    }

    // MARK: - Expand/Collapse

    func toggleExpanded(_ todoId: UUID) {
        if expandedTodoIds.contains(todoId) {
            expandedTodoIds.remove(todoId)
        } else {
            expandedTodoIds.insert(todoId)
        }
        HapticManager.shared.selection()
    }

    func isExpanded(_ todoId: UUID) -> Bool {
        expandedTodoIds.contains(todoId)
    }

    func collapseAll() {
        expandedTodoIds.removeAll()
    }

    // MARK: - CRUD Operations

    func addTodo(_ todo: TodoItem) {
        // Set order index to end of list for the priority group
        let priorityTodos = todos.filter { $0.priorityEnum == todo.priorityEnum && !$0.isCompleted }
        todo.orderIndex = priorityTodos.count
        modelContext?.insert(todo)
        save()
        todos.append(todo)
        HapticManager.shared.notification(.success)
    }

    func deleteTodo(_ todo: TodoItem) {
        modelContext?.delete(todo)
        save()
        todos.removeAll { $0.id == todo.id }
        expandedTodoIds.remove(todo.id)
        // Reindex
        reindexTodos()
        HapticManager.shared.deleted()
    }

    func toggleCompletion(for todo: TodoItem) {
        todo.toggleCompletion()
        save()
        HapticManager.shared.taskCompleted()
    }

    func addSubtask(to todo: TodoItem, title: String) {
        todo.addSubtask(title)
        save()
        HapticManager.shared.notification(.success)
    }

    func toggleSubtask(_ subtask: TodoSubtask, in todo: TodoItem) {
        subtask.toggle()
        todo.updatedAt = Date()
        save()
        HapticManager.shared.selection()
    }

    func deleteSubtask(_ subtask: TodoSubtask, from todo: TodoItem) {
        todo.removeSubtask(subtask)
        save()
        HapticManager.shared.deleted()
    }

    func updatePriority(for todo: TodoItem, to priority: TodoPriority) {
        todo.setPriority(priority)
        save()
        // Trigger array refresh to update computed properties
        fetchTodos()
        HapticManager.shared.notification(.success)
    }

    // MARK: - Reordering

    private func reindexTodos() {
        // Reindex within each priority group
        for priority in TodoPriority.allCases {
            let priorityTodos = todos.filter { $0.priorityEnum == priority && !$0.isCompleted }
                .sorted { $0.orderIndex < $1.orderIndex }
            for (index, todo) in priorityTodos.enumerated() {
                todo.orderIndex = index
            }
        }
        save()
    }

    func moveTodo(from source: IndexSet, to destination: Int, in priority: TodoPriority) {
        var filteredTodos = todos.filter { $0.priorityEnum == priority && !$0.isCompleted }
        filteredTodos.move(fromOffsets: source, toOffset: destination)

        // Update order indices
        for (index, todo) in filteredTodos.enumerated() {
            todo.orderIndex = index
        }

        save()
        HapticManager.shared.selection()
    }

    // MARK: - Sample Data

    func loadSampleData() {
        let todo1 = TodoItem(
            title: "Weekly shopping",
            icon: "🛒",
            colorName: "sage",
            priority: .high
        )
        todo1.addSubtask("Milk")
        todo1.subtasks.first?.toggle() // Mark first as completed
        todo1.addSubtask("Bread")
        todo1.addSubtask("Eggs")
        todo1.addSubtask("Vegetables")
        todo1.addSubtask("Chicken")

        let todo2 = TodoItem(
            title: "Doctor appointment prep",
            icon: "🏥",
            colorName: "sky",
            priority: .high
        )
        todo2.addSubtask("Confirm appointment time")
        todo2.subtasks.first?.toggle()
        todo2.addSubtask("Gather test results")
        todo2.addSubtask("Write down questions")
        todo2.addSubtask("Check insurance card")

        let todo3 = TodoItem(
            title: "Party planning",
            icon: "🎉",
            colorName: "rose",
            priority: .medium
        )
        todo3.addSubtask("Send invitations")
        todo3.addSubtask("Order cake")
        todo3.addSubtask("Buy decorations")
        todo3.addSubtask("Plan games")
        todo3.addSubtask("Make playlist")

        let todo4 = TodoItem(
            title: "Snowdonia trip",
            icon: "🏔️",
            colorName: "amber",
            priority: .medium
        )

        let todo5 = TodoItem(
            title: "Complete physics book",
            icon: "📚",
            colorName: "lavender",
            priority: .low
        )
        todo5.addSubtask("Chapter 5: Waves")
        todo5.subtasks.first?.toggle()
        todo5.addSubtask("Chapter 6: Optics")
        todo5.addSubtask("Practice problems")

        [todo1, todo2, todo3, todo4, todo5].forEach { addTodo($0) }
    }
}
