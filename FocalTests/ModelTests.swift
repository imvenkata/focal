import XCTest
import SwiftData
@testable import Focal

final class ModelTests: XCTestCase {

    // MARK: - TaskItem Tests

    func testTaskItem_endTimeCalculation() throws {
        // Given
        let startTime = TestHelpers.todayAt(hour: 10, minute: 0)
        let duration: TimeInterval = 3600 // 1 hour

        let task = TaskItem(
            title: "Test Task",
            icon: "@",
            colorName: "coral",
            startTime: startTime,
            duration: duration
        )

        // When
        let endTime = task.endTime

        // Then
        let expectedEndTime = TestHelpers.todayAt(hour: 11, minute: 0)
        let calendar = Calendar.current
        XCTAssertEqual(
            calendar.component(.hour, from: endTime),
            calendar.component(.hour, from: expectedEndTime)
        )
        XCTAssertEqual(
            calendar.component(.minute, from: endTime),
            calendar.component(.minute, from: expectedEndTime)
        )
    }

    func testTaskItem_durationFormatted() throws {
        // Given - 1 hour 30 minutes
        let task = TaskItem(
            title: "Test Task",
            icon: "@",
            colorName: "coral",
            startTime: Date(),
            duration: 5400 // 90 minutes
        )

        // When
        let formatted = task.durationFormatted

        // Then
        XCTAssertTrue(formatted.contains("1") && formatted.contains("30") ||
                      formatted == "1h 30m" ||
                      formatted == "1:30")
    }

    func testTaskItem_toggleCompletion() throws {
        // Given
        let task = TaskItem(
            title: "Test Task",
            icon: "@",
            colorName: "coral",
            startTime: Date(),
            duration: 3600
        )
        XCTAssertFalse(task.isCompleted)

        // When
        task.toggleCompletion()

        // Then
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)

        // Toggle back
        task.toggleCompletion()
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)
    }

    func testTaskItem_addSubtask() throws {
        // Given
        let task = TaskItem(
            title: "Test Task",
            icon: "@",
            colorName: "coral",
            startTime: Date(),
            duration: 3600
        )
        XCTAssertEqual(task.subtasks.count, 0)

        // When
        task.addSubtask("Subtask 1")
        task.addSubtask("Subtask 2")

        // Then
        XCTAssertEqual(task.subtasks.count, 2)
        XCTAssertEqual(task.subtasks[0].title, "Subtask 1")
        XCTAssertEqual(task.subtasks[1].title, "Subtask 2")
    }

    func testTaskItem_subtasksProgress() throws {
        // Given
        let task = TaskItem(
            title: "Test Task",
            icon: "@",
            colorName: "coral",
            startTime: Date(),
            duration: 3600
        )
        task.addSubtask("Subtask 1")
        task.addSubtask("Subtask 2")
        task.addSubtask("Subtask 3")

        // When - Complete 2 of 3 subtasks
        task.subtasks[0].toggle()
        task.subtasks[1].toggle()

        // Then
        XCTAssertEqual(task.subtasksProgress, 2.0/3.0, accuracy: 0.01)
        XCTAssertEqual(task.completedSubtasksCount, 2)
    }

    // MARK: - TodoItem Tests

    func testTodoItem_isOverdue() throws {
        // Given - Todo due yesterday
        let todo = TodoItem(
            title: "Overdue Todo",
            icon: "@",
            colorName: "sage",
            priority: .medium
        )
        todo.setDueDate(TestHelpers.yesterday())

        // Then
        XCTAssertTrue(todo.isOverdue)
    }

    func testTodoItem_isNotOverdue_whenDueToday() throws {
        // Given - Todo due today
        let todo = TodoItem(
            title: "Today Todo",
            icon: "@",
            colorName: "sage",
            priority: .medium
        )
        todo.setDueDate(Date())

        // Then - Due today is not overdue
        XCTAssertFalse(todo.isOverdue)
    }

    func testTodoItem_isNotOverdue_whenCompleted() throws {
        // Given - Completed todo that was due yesterday
        let todo = TodoItem(
            title: "Completed Todo",
            icon: "@",
            colorName: "sage",
            priority: .medium
        )
        todo.setDueDate(TestHelpers.yesterday())
        todo.toggleCompletion()

        // Then - Completed todos are not overdue
        XCTAssertFalse(todo.isOverdue)
    }

    func testTodoItem_isDueToday() throws {
        // Given
        let todo = TodoItem(
            title: "Today Todo",
            icon: "@",
            colorName: "sage",
            priority: .medium
        )
        todo.setDueDate(Date())

        // Then
        XCTAssertTrue(todo.isDueToday)
    }

    func testTodoItem_subtasksProgress() throws {
        // Given
        let todo = TodoItem(
            title: "Todo with Subtasks",
            icon: "@",
            colorName: "sage",
            priority: .medium
        )
        todo.addSubtask("Step 1")
        todo.addSubtask("Step 2")
        todo.addSubtask("Step 3")
        todo.addSubtask("Step 4")

        // When - Complete 3 of 4
        todo.subtasks[0].toggle()
        todo.subtasks[1].toggle()
        todo.subtasks[2].toggle()

        // Then
        XCTAssertEqual(todo.subtasksProgress, 0.75, accuracy: 0.01)
        XCTAssertEqual(todo.completedSubtasksCount, 3)
        XCTAssertEqual(todo.totalSubtasks, 4)
    }

    // MARK: - Priority Tests

    func testTodoPriority_ordering() throws {
        // Given
        let highTodo = TodoItem(title: "High", icon: "@", colorName: "coral", priority: .high)
        let mediumTodo = TodoItem(title: "Medium", icon: "@", colorName: "sage", priority: .medium)
        let lowTodo = TodoItem(title: "Low", icon: "@", colorName: "sky", priority: .low)

        // Then
        XCTAssertEqual(highTodo.priorityEnum.sortOrder, 0)
        XCTAssertEqual(mediumTodo.priorityEnum.sortOrder, 1)
        XCTAssertEqual(lowTodo.priorityEnum.sortOrder, 2)
    }

    // MARK: - TaskColor Tests

    func testTaskColor_allCasesAvailable() throws {
        // Then
        XCTAssertEqual(TaskColor.allCases.count, 8)
        XCTAssertTrue(TaskColor.allCases.contains(.coral))
        XCTAssertTrue(TaskColor.allCases.contains(.sage))
        XCTAssertTrue(TaskColor.allCases.contains(.sky))
        XCTAssertTrue(TaskColor.allCases.contains(.lavender))
        XCTAssertTrue(TaskColor.allCases.contains(.amber))
        XCTAssertTrue(TaskColor.allCases.contains(.rose))
        XCTAssertTrue(TaskColor.allCases.contains(.slate))
        XCTAssertTrue(TaskColor.allCases.contains(.night))
    }

    // MARK: - EnergyLevel Tests

    func testEnergyLevel_iconMapping() throws {
        // Given
        let task0 = TaskItem(title: "Rest", icon: "@", colorName: "coral", startTime: Date(), duration: 3600, energyLevel: 0)
        let task2 = TaskItem(title: "Moderate", icon: "@", colorName: "coral", startTime: Date(), duration: 3600, energyLevel: 2)
        let task4 = TaskItem(title: "Intense", icon: "@", colorName: "coral", startTime: Date(), duration: 3600, energyLevel: 4)

        // Then
        XCTAssertFalse(task0.energyIcon.isEmpty)
        XCTAssertFalse(task2.energyIcon.isEmpty)
        XCTAssertFalse(task4.energyIcon.isEmpty)
    }
}
