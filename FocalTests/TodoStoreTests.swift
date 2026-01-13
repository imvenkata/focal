import XCTest
import SwiftData
@testable import Focal

final class TodoStoreTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var todoStore: TodoStore!

    override func setUpWithError() throws {
        modelContainer = try TestHelpers.createTestModelContainer()
        modelContext = ModelContext(modelContainer)
        todoStore = TodoStore()
        todoStore.setModelContext(modelContext)
    }

    override func tearDownWithError() throws {
        todoStore = nil
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - Add Todo Tests

    func testAddTodo_setsOrderIndex() throws {
        // Given
        let todo1 = TestHelpers.createSampleTodo(title: "First")
        let todo2 = TestHelpers.createSampleTodo(title: "Second")

        // When
        todoStore.addTodo(todo1)
        todoStore.addTodo(todo2)

        // Then
        XCTAssertEqual(todoStore.todos.count, 2)
        // Order indices should be set
        XCTAssertNotEqual(todo1.orderIndex, todo2.orderIndex)
    }

    func testAddTodo_appendsToList() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "New Todo")

        // When
        todoStore.addTodo(todo)

        // Then
        XCTAssertEqual(todoStore.todos.count, 1)
        XCTAssertEqual(todoStore.todos.first?.title, "New Todo")
    }

    // MARK: - Delete Todo Tests

    func testDeleteTodo_withUndo() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Delete Me")
        todoStore.addTodo(todo)
        XCTAssertEqual(todoStore.todos.count, 1)

        // When
        todoStore.deleteTodo(todo, withUndo: true)

        // Then
        XCTAssertEqual(todoStore.todos.count, 0)
        XCTAssertNotNil(todoStore.recentlyDeletedTodo)
    }

    func testDeleteTodo_withoutUndo() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Delete Me")
        todoStore.addTodo(todo)

        // When
        todoStore.deleteTodo(todo, withUndo: false)

        // Then
        XCTAssertEqual(todoStore.todos.count, 0)
        XCTAssertNil(todoStore.recentlyDeletedTodo)
    }

    // MARK: - Undo Delete Tests

    func testUndoDelete_restoresTodo() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Restore Me")
        todoStore.addTodo(todo)
        todoStore.deleteTodo(todo, withUndo: true)
        XCTAssertEqual(todoStore.todos.count, 0)

        // When
        todoStore.undoDelete()

        // Then
        XCTAssertEqual(todoStore.todos.count, 1)
        XCTAssertEqual(todoStore.todos.first?.title, "Restore Me")
        XCTAssertNil(todoStore.recentlyDeletedTodo)
    }

    // MARK: - Toggle Completion Tests

    func testToggleCompletion_updatesCompletedAt() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Complete Me")
        todoStore.addTodo(todo)
        XCTAssertFalse(todo.isCompleted)
        XCTAssertNil(todo.completedAt)

        // When
        todoStore.toggleCompletion(for: todo)

        // Then
        XCTAssertTrue(todo.isCompleted)
        XCTAssertNotNil(todo.completedAt)
    }

    func testToggleCompletion_twice() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Toggle Me")
        todoStore.addTodo(todo)

        // When
        todoStore.toggleCompletion(for: todo)
        todoStore.toggleCompletion(for: todo)

        // Then
        XCTAssertFalse(todo.isCompleted)
        XCTAssertNil(todo.completedAt)
    }

    // MARK: - Filter Tests

    func testFilteredTodos_byToday() throws {
        // Given
        let todayTodo = TestHelpers.createSampleTodo(title: "Today", dueDate: Date())
        let tomorrowTodo = TestHelpers.createSampleTodo(title: "Tomorrow", dueDate: TestHelpers.tomorrow())
        let noDueTodo = TestHelpers.createSampleTodo(title: "No Date")

        todoStore.addTodo(todayTodo)
        todoStore.addTodo(tomorrowTodo)
        todoStore.addTodo(noDueTodo)

        // When
        todoStore.selectedFilter = .today

        // Then
        let filtered = todoStore.filteredTodos
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Today")
    }

    func testFilteredTodos_byOverdue() throws {
        // Given
        let overdueTodo = TestHelpers.createOverdueTodo(title: "Overdue")
        let todayTodo = TestHelpers.createSampleTodo(title: "Today", dueDate: Date())

        todoStore.addTodo(overdueTodo)
        todoStore.addTodo(todayTodo)

        // When
        todoStore.selectedFilter = .overdue

        // Then
        let filtered = todoStore.filteredTodos
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Overdue")
    }

    // MARK: - Archive Tests

    func testArchiveTodo() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Archive Me")
        todoStore.addTodo(todo)
        XCTAssertFalse(todo.isArchived)

        // When
        todoStore.archiveTodo(todo)

        // Then
        XCTAssertTrue(todo.isArchived)
    }

    func testUnarchiveTodo() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Unarchive Me")
        todoStore.addTodo(todo)
        todo.archive()

        // When
        todoStore.unarchiveTodo(todo)

        // Then
        XCTAssertFalse(todo.isArchived)
    }

    // MARK: - Priority Tests

    func testUpdatePriority() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Update Priority", priority: .low)
        todoStore.addTodo(todo)

        // When
        todoStore.updatePriority(for: todo, to: .high)

        // Then
        XCTAssertEqual(todo.priorityEnum, .high)
    }

    // MARK: - Search Tests

    func testSearchText_filtersByTitle() throws {
        // Given
        let todo1 = TestHelpers.createSampleTodo(title: "Buy groceries")
        let todo2 = TestHelpers.createSampleTodo(title: "Call mom")
        let todo3 = TestHelpers.createSampleTodo(title: "Buy flowers")

        todoStore.addTodo(todo1)
        todoStore.addTodo(todo2)
        todoStore.addTodo(todo3)

        // When
        todoStore.searchText = "Buy"

        // Then
        let filtered = todoStore.filteredTodos
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { $0.title.contains("Buy") })
    }

    func testSearchText_caseInsensitive() throws {
        // Given
        let todo = TestHelpers.createSampleTodo(title: "Important Task")
        todoStore.addTodo(todo)

        // When
        todoStore.searchText = "important"

        // Then
        let filtered = todoStore.filteredTodos
        XCTAssertEqual(filtered.count, 1)
    }

    // MARK: - Move Todo Tests

    func testMoveTodo_reindexesCorrectly() throws {
        // Given
        let todo1 = TestHelpers.createSampleTodo(title: "First", priority: .high)
        let todo2 = TestHelpers.createSampleTodo(title: "Second", priority: .high)
        let todo3 = TestHelpers.createSampleTodo(title: "Third", priority: .high)

        todoStore.addTodo(todo1)
        todoStore.addTodo(todo2)
        todoStore.addTodo(todo3)

        let originalOrder = [todo1.orderIndex, todo2.orderIndex, todo3.orderIndex]

        // When - Move first to last position
        todoStore.moveTodo(from: IndexSet(integer: 0), to: 3, in: .high)

        // Then - Order should have changed
        let newOrder = [todo1.orderIndex, todo2.orderIndex, todo3.orderIndex]
        XCTAssertNotEqual(originalOrder, newOrder)
    }
}
