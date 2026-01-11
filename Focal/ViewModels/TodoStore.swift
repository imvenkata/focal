import SwiftUI
import SwiftData

@Observable
final class TodoStore {
    private var modelContext: ModelContext?
    var todos: [TodoItem] = []
    var expandedTodoIds: Set<UUID> = []
    var collapsedSections: Set<TodoPriority> = []

    // MARK: - Search & Filter
    var searchText: String = ""
    var selectedFilter: TodoFilter = .all
    var showCompletedSection: Bool = true
    var isCompletedSectionCollapsed: Bool = true

    // MARK: - Undo Support
    private var recentlyDeletedTodo: TodoItem?
    private var undoTimer: Timer?
    var canUndo: Bool { recentlyDeletedTodo != nil }
    var undoMessage: String? {
        guard let todo = recentlyDeletedTodo else { return nil }
        return "Deleted \"\(todo.title)\""
    }

    // MARK: - Selection for Bulk Operations
    var selectedTodoIds: Set<UUID> = []
    var isSelectionMode: Bool = false

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
        todos.filter { $0.isCompleted && !$0.isArchived }
            .sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    var activeTodos: [TodoItem] {
        todos.filter { !$0.isCompleted && !$0.isArchived }
    }

    var archivedTodos: [TodoItem] {
        todos.filter { $0.isArchived }
    }

    var completionProgress: Double {
        let active = todos.filter { !$0.isArchived }
        guard !active.isEmpty else { return 0 }
        return Double(active.filter { $0.isCompleted }.count) / Double(active.count)
    }

    // MARK: - Filtered & Searched Results

    var filteredTodos: [TodoItem] {
        var result = todos.filter { !$0.isArchived }

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .today:
            result = result.filter { $0.isDueToday || ($0.dueDate == nil && Calendar.current.isDateInToday($0.createdAt)) }
        case .upcoming:
            result = result.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate > Date() && !todo.isDueToday
            }
        case .overdue:
            result = result.filter { $0.isOverdue }
        case .noDueDate:
            result = result.filter { $0.dueDate == nil }
        }

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { todo in
                todo.title.lowercased().contains(query) ||
                todo.notes?.lowercased().contains(query) == true ||
                todo.subtasks.contains { $0.title.lowercased().contains(query) }
            }
        }

        return result
    }

    var filteredHighPriorityTodos: [TodoItem] {
        filteredTodos.filter { $0.priorityEnum == .high && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var filteredMediumPriorityTodos: [TodoItem] {
        filteredTodos.filter { $0.priorityEnum == .medium && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var filteredLowPriorityTodos: [TodoItem] {
        filteredTodos.filter { $0.priorityEnum == .low && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var filteredUnprioritizedTodos: [TodoItem] {
        filteredTodos.filter { $0.priorityEnum == .none && !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var filteredCompletedTodos: [TodoItem] {
        filteredTodos.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    // MARK: - Statistics

    var todayCompletedCount: Int {
        todos.filter { todo in
            guard let completedAt = todo.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }.count
    }

    var weekCompletedCount: Int {
        todos.filter { todo in
            guard let completedAt = todo.completedAt else { return false }
            return Calendar.current.isDate(completedAt, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
    }

    var overdueCount: Int {
        activeTodos.filter { $0.isOverdue }.count
    }

    var dueTodayCount: Int {
        activeTodos.filter { $0.isDueToday }.count
    }

    var totalActiveCount: Int {
        activeTodos.count
    }

    var hasAnyTodos: Bool {
        !todos.filter { !$0.isArchived }.isEmpty
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

    func deleteTodo(_ todo: TodoItem, withUndo: Bool = true) {
        if withUndo {
            // Store for undo
            recentlyDeletedTodo = todo
            todos.removeAll { $0.id == todo.id }
            expandedTodoIds.remove(todo.id)

            // Start undo timer (5 seconds to undo)
            undoTimer?.invalidate()
            undoTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.commitDelete()
            }
        } else {
            modelContext?.delete(todo)
            save()
            todos.removeAll { $0.id == todo.id }
            expandedTodoIds.remove(todo.id)
        }

        reindexTodos()
        HapticManager.shared.deleted()
    }

    func undoDelete() {
        guard let todo = recentlyDeletedTodo else { return }
        undoTimer?.invalidate()
        undoTimer = nil

        // Re-add the todo
        todos.append(todo)
        reindexTodos()
        recentlyDeletedTodo = nil
        HapticManager.shared.notification(.success)
    }

    private func commitDelete() {
        guard let todo = recentlyDeletedTodo else { return }
        modelContext?.delete(todo)
        save()
        recentlyDeletedTodo = nil
        undoTimer = nil
    }

    func toggleCompletion(for todo: TodoItem) {
        todo.toggleCompletion()
        save()
        HapticManager.shared.taskCompleted()
    }

    // MARK: - Archive Operations

    func archiveTodo(_ todo: TodoItem) {
        todo.archive()
        save()
        HapticManager.shared.notification(.success)
    }

    func unarchiveTodo(_ todo: TodoItem) {
        todo.unarchive()
        save()
        fetchTodos()
        HapticManager.shared.notification(.success)
    }

    func archiveAllCompleted() {
        for todo in completedTodos {
            todo.archive()
        }
        save()
        HapticManager.shared.notification(.success)
    }

    func deleteAllArchived() {
        for todo in archivedTodos {
            modelContext?.delete(todo)
        }
        save()
        fetchTodos()
        HapticManager.shared.deleted()
    }

    // MARK: - Bulk Operations

    func toggleSelection(_ todoId: UUID) {
        if selectedTodoIds.contains(todoId) {
            selectedTodoIds.remove(todoId)
        } else {
            selectedTodoIds.insert(todoId)
        }
        HapticManager.shared.selection()
    }

    func selectAll() {
        selectedTodoIds = Set(filteredTodos.map { $0.id })
        HapticManager.shared.selection()
    }

    func deselectAll() {
        selectedTodoIds.removeAll()
        isSelectionMode = false
        HapticManager.shared.selection()
    }

    func deleteSelected() {
        for id in selectedTodoIds {
            if let todo = todos.first(where: { $0.id == id }) {
                deleteTodo(todo, withUndo: false)
            }
        }
        selectedTodoIds.removeAll()
        isSelectionMode = false
    }

    func completeSelected() {
        for id in selectedTodoIds {
            if let todo = todos.first(where: { $0.id == id }), !todo.isCompleted {
                todo.toggleCompletion()
            }
        }
        save()
        selectedTodoIds.removeAll()
        isSelectionMode = false
        HapticManager.shared.taskCompleted()
    }

    func archiveSelected() {
        for id in selectedTodoIds {
            if let todo = todos.first(where: { $0.id == id }) {
                todo.archive()
            }
        }
        save()
        selectedTodoIds.removeAll()
        isSelectionMode = false
        HapticManager.shared.notification(.success)
    }

    func setPriorityForSelected(_ priority: TodoPriority) {
        for id in selectedTodoIds {
            if let todo = todos.first(where: { $0.id == id }) {
                todo.setPriority(priority)
            }
        }
        save()
        fetchTodos()
        HapticManager.shared.notification(.success)
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

// MARK: - Todo Filter

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case upcoming = "Upcoming"
    case overdue = "Overdue"
    case noDueDate = "No Date"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "tray.full"
        case .today: return "sun.max"
        case .upcoming: return "calendar"
        case .overdue: return "exclamationmark.circle"
        case .noDueDate: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .all: return DS.Colors.primary
        case .today: return DS.Colors.amber
        case .upcoming: return DS.Colors.sky
        case .overdue: return DS.Colors.danger
        case .noDueDate: return DS.Colors.slate
        }
    }
}
