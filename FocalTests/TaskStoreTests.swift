import XCTest
import SwiftData
@testable import Focal

final class TaskStoreTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var taskStore: TaskStore!

    override func setUpWithError() throws {
        modelContainer = try TestHelpers.createTestModelContainer()
        modelContext = ModelContext(modelContainer)
        taskStore = TaskStore()
        taskStore.setModelContext(modelContext)
    }

    override func tearDownWithError() throws {
        taskStore = nil
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - Add Task Tests

    func testAddTask() throws {
        // Given
        let task = TestHelpers.createSampleTask(title: "New Task")

        // When
        taskStore.addTask(task)

        // Then
        XCTAssertEqual(taskStore.tasks.count, 1)
        XCTAssertEqual(taskStore.tasks.first?.title, "New Task")
    }

    func testAddMultipleTasks() throws {
        // Given
        let task1 = TestHelpers.createSampleTask(title: "Task 1")
        let task2 = TestHelpers.createSampleTask(title: "Task 2")
        let task3 = TestHelpers.createSampleTask(title: "Task 3")

        // When
        taskStore.addTask(task1)
        taskStore.addTask(task2)
        taskStore.addTask(task3)

        // Then
        XCTAssertEqual(taskStore.tasks.count, 3)
    }

    // MARK: - Delete Task Tests

    func testDeleteTask() throws {
        // Given
        let task = TestHelpers.createSampleTask(title: "To Delete")
        taskStore.addTask(task)
        XCTAssertEqual(taskStore.tasks.count, 1)

        // When
        taskStore.deleteTask(task)

        // Then
        XCTAssertEqual(taskStore.tasks.count, 0)
    }

    func testDeleteTaskRemovesCompletionRecords() throws {
        // Given
        let task = TestHelpers.createDailyTask(title: "Recurring Task")
        taskStore.addTask(task)

        // Create a completion record
        let record = TaskCompletionRecord(taskId: task.id, completedDate: Date())
        modelContext.insert(record)
        try modelContext.save()

        // When
        taskStore.deleteTask(task)

        // Then
        XCTAssertEqual(taskStore.tasks.count, 0)
        // The completion record should also be deleted
        let descriptor = FetchDescriptor<TaskCompletionRecord>()
        let records = try modelContext.fetch(descriptor)
        XCTAssertEqual(records.count, 0)
    }

    // MARK: - Toggle Completion Tests

    func testToggleCompletion() throws {
        // Given
        let task = TestHelpers.createSampleTask(title: "Complete Me")
        taskStore.addTask(task)
        XCTAssertFalse(task.isCompleted)

        // When
        taskStore.toggleCompletion(for: task)

        // Then
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }

    func testToggleCompletionTwice() throws {
        // Given
        let task = TestHelpers.createSampleTask(title: "Toggle Twice")
        taskStore.addTask(task)

        // When
        taskStore.toggleCompletion(for: task)
        taskStore.toggleCompletion(for: task)

        // Then
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)
    }

    // MARK: - Tasks For Selected Date Tests

    func testTasksForSelectedDate_filtersCorrectly() throws {
        // Given
        let today = Date()
        let tomorrow = TestHelpers.tomorrow()

        let todayTask = TestHelpers.createSampleTask(
            title: "Today Task",
            startTime: TestHelpers.todayAt(hour: 10)
        )
        let tomorrowTask = TestHelpers.createSampleTask(
            title: "Tomorrow Task",
            startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!
        )

        taskStore.addTask(todayTask)
        taskStore.addTask(tomorrowTask)
        taskStore.selectedDate = today

        // When
        let todayTasks = taskStore.tasksForSelectedDate

        // Then
        XCTAssertEqual(todayTasks.count, 1)
        XCTAssertEqual(todayTasks.first?.title, "Today Task")
    }

    func testTasksForSelectedDate_sortsByTime() throws {
        // Given
        let task1 = TestHelpers.createSampleTask(
            title: "Later Task",
            startTime: TestHelpers.todayAt(hour: 14)
        )
        let task2 = TestHelpers.createSampleTask(
            title: "Earlier Task",
            startTime: TestHelpers.todayAt(hour: 9)
        )

        taskStore.addTask(task1)
        taskStore.addTask(task2)
        taskStore.selectedDate = Date()

        // When
        let tasks = taskStore.tasksForSelectedDate

        // Then
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks[0].title, "Earlier Task")
        XCTAssertEqual(tasks[1].title, "Later Task")
    }

    // MARK: - Progress Tests

    func testProgressForSelectedDate() throws {
        // Given
        let task1 = TestHelpers.createSampleTask(
            title: "Task 1",
            startTime: TestHelpers.todayAt(hour: 9),
            isCompleted: true
        )
        let task2 = TestHelpers.createSampleTask(
            title: "Task 2",
            startTime: TestHelpers.todayAt(hour: 10),
            isCompleted: false
        )

        taskStore.addTask(task1)
        taskStore.addTask(task2)
        taskStore.selectedDate = Date()

        // When
        let progress = taskStore.progressForSelectedDate

        // Then
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }

    func testProgressForSelectedDate_noTasks() throws {
        // Given
        taskStore.selectedDate = Date()

        // When
        let progress = taskStore.progressForSelectedDate

        // Then
        XCTAssertEqual(progress, 0.0)
    }

    // MARK: - Move Task Tests

    func testMoveTaskToDate() throws {
        // Given
        let task = TestHelpers.createSampleTask(
            title: "Move Me",
            startTime: TestHelpers.todayAt(hour: 10)
        )
        taskStore.addTask(task)
        let tomorrow = TestHelpers.tomorrow()

        // When
        taskStore.moveTask(task, toDate: tomorrow)

        // Then
        XCTAssertTrue(task.startTime.isSameDay(as: tomorrow))
        // Time should be preserved
        XCTAssertEqual(Calendar.current.component(.hour, from: task.startTime), 10)
    }

    func testMoveTaskToDateWithTime() throws {
        // Given
        let task = TestHelpers.createSampleTask(
            title: "Move Me",
            startTime: TestHelpers.todayAt(hour: 10)
        )
        taskStore.addTask(task)
        let tomorrow = TestHelpers.tomorrow()

        // When
        taskStore.moveTask(task, toDate: tomorrow, hour: 15, minute: 30)

        // Then
        XCTAssertTrue(task.startTime.isSameDay(as: tomorrow))
        XCTAssertEqual(Calendar.current.component(.hour, from: task.startTime), 15)
        XCTAssertEqual(Calendar.current.component(.minute, from: task.startTime), 30)
    }

    // MARK: - Total Energy Tests

    func testTotalEnergyForSelectedDate() throws {
        // Given
        let task1 = TestHelpers.createSampleTask(
            title: "Task 1",
            startTime: TestHelpers.todayAt(hour: 9),
            energyLevel: 3
        )
        let task2 = TestHelpers.createSampleTask(
            title: "Task 2",
            startTime: TestHelpers.todayAt(hour: 10),
            energyLevel: 4
        )

        taskStore.addTask(task1)
        taskStore.addTask(task2)
        taskStore.selectedDate = Date()

        // When
        let totalEnergy = taskStore.totalEnergyForSelectedDate

        // Then
        XCTAssertEqual(totalEnergy, 7)
    }

    // MARK: - Week Progress Tests

    func testCurrentWeekProgress() throws {
        // Given - Add tasks for multiple days this week
        let calendar = Calendar.current
        let weekStart = Date().startOfWeek

        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart)!
            let task = TestHelpers.createSampleTask(
                title: "Task \(i)",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!,
                isCompleted: i < 2 // First two completed
            )
            taskStore.addTask(task)
        }

        taskStore.selectedDate = weekStart

        // When
        let progress = taskStore.currentWeekProgress

        // Then
        XCTAssertEqual(progress, 2.0/3.0, accuracy: 0.01)
    }
}
