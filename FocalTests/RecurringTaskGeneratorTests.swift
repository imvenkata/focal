import XCTest
import SwiftData
@testable import Focal

final class RecurringTaskGeneratorTests: XCTestCase {

    // MARK: - Daily Recurrence Tests

    func testDailyRecurrence_generatesAllDays() throws {
        // Given
        let startDate = TestHelpers.todayAt(hour: 9)
        let task = TestHelpers.createDailyTask(title: "Daily Task", startTime: startDate)

        let rangeStart = startDate
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!

        // When
        let instances = RecurringTaskGenerator.generateOccurrences(
            for: task,
            in: rangeStart...rangeEnd
        )

        // Then
        XCTAssertEqual(instances.count, 7) // 7 days including start and end
        XCTAssertTrue(instances.allSatisfy { $0.isVirtual })
    }

    func testDailyRecurrence_occursOnAnyDay() throws {
        // Given
        let task = TestHelpers.createDailyTask(title: "Daily Task", startTime: Date())

        // When/Then
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: Date()))
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: TestHelpers.tomorrow()))
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: TestHelpers.daysFromNow(7)))
    }

    // MARK: - Weekly Recurrence Tests

    func testWeeklyRecurrence_matchesWeekday() throws {
        // Given - Create a task on a Monday
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!

        let task = TestHelpers.createWeeklyTask(title: "Weekly Task", startTime: monday)

        // When - Check next Monday
        let nextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: monday)!

        // Then
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: nextMonday))
    }

    func testWeeklyRecurrence_doesNotOccurOnWrongDay() throws {
        // Given - Create a task on a Monday
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!

        let task = TestHelpers.createWeeklyTask(title: "Weekly Task", startTime: monday)

        // When - Check Tuesday
        let tuesday = calendar.date(byAdding: .day, value: 1, to: monday)!

        // Then
        XCTAssertFalse(RecurringTaskGenerator.occurs(task: task, on: tuesday))
    }

    // MARK: - Custom Recurrence Tests

    func testCustomRecurrence_matchesSelectedDays() throws {
        // Given - Task repeats on Mon (1), Wed (3), Fri (5)
        let task = TestHelpers.createCustomRecurrenceTask(
            title: "Custom Task",
            startTime: Date(),
            repeatDays: [1, 3, 5]
        )

        // When - Find the next Monday, Wednesday, Friday
        let calendar = Calendar.current
        var checkDate = Date()
        var mondayFound = false
        var wednesdayFound = false
        var fridayFound = false
        var tuesdayFound = false

        // Check the next 7 days
        for _ in 0..<7 {
            let weekday = calendar.component(.weekday, from: checkDate)
            let dayIndex = weekday - 1 // Convert to 0-based (Sunday = 0)

            let occurs = RecurringTaskGenerator.occurs(task: task, on: checkDate)

            if dayIndex == 1 { // Monday
                mondayFound = occurs
            } else if dayIndex == 2 { // Tuesday
                tuesdayFound = occurs
            } else if dayIndex == 3 { // Wednesday
                wednesdayFound = occurs
            } else if dayIndex == 5 { // Friday
                fridayFound = occurs
            }

            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
        }

        // Then
        XCTAssertTrue(mondayFound, "Should occur on Monday")
        XCTAssertTrue(wednesdayFound, "Should occur on Wednesday")
        XCTAssertTrue(fridayFound, "Should occur on Friday")
        XCTAssertFalse(tuesdayFound, "Should NOT occur on Tuesday")
    }

    // MARK: - Monthly Recurrence Tests

    func testMonthlyRecurrence_handlesEdgeCases() throws {
        // Given - Task on the 15th of the month
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = 15
        components.hour = 10
        let fifteenthOfMonth = calendar.date(from: components)!

        let task = TestHelpers.createSampleTask(
            title: "Monthly Task",
            startTime: fifteenthOfMonth,
            recurrenceOption: "Monthly"
        )

        // When - Check next month's 15th
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: fifteenthOfMonth)!

        // Then
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: nextMonth))
    }

    // MARK: - Occurs Tests

    func testOccurs_correctDay_returnsTrue() throws {
        // Given
        let task = TestHelpers.createDailyTask(title: "Daily", startTime: Date())

        // When/Then
        XCTAssertTrue(RecurringTaskGenerator.occurs(task: task, on: TestHelpers.tomorrow()))
    }

    func testOccurs_wrongDay_returnsFalse() throws {
        // Given - Weekly task
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!

        let task = TestHelpers.createWeeklyTask(title: "Weekly", startTime: monday)

        // When - Check a Wednesday
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!

        // Then
        XCTAssertFalse(RecurringTaskGenerator.occurs(task: task, on: wednesday))
    }

    func testOccurs_beforeTaskStart_returnsFalse() throws {
        // Given - Task starts tomorrow
        let task = TestHelpers.createDailyTask(
            title: "Future Task",
            startTime: TestHelpers.tomorrow()
        )

        // When - Check today (before start)
        let today = Date()

        // Then
        XCTAssertFalse(RecurringTaskGenerator.occurs(task: task, on: today))
    }

    // MARK: - Non-Recurring Task Tests

    func testOccurs_nonRecurringTask_returnsFalse() throws {
        // Given - Task without recurrence
        let task = TestHelpers.createSampleTask(title: "One-time Task")

        // When/Then
        XCTAssertFalse(RecurringTaskGenerator.occurs(task: task, on: TestHelpers.tomorrow()))
    }

    func testIsRecurring_withRecurrence_returnsTrue() throws {
        // Given
        let dailyTask = TestHelpers.createDailyTask(title: "Daily")
        let weeklyTask = TestHelpers.createWeeklyTask(title: "Weekly")

        // When/Then
        XCTAssertTrue(RecurringTaskGenerator.isRecurring(dailyTask))
        XCTAssertTrue(RecurringTaskGenerator.isRecurring(weeklyTask))
    }

    func testIsRecurring_withoutRecurrence_returnsFalse() throws {
        // Given
        let task = TestHelpers.createSampleTask(title: "One-time")

        // When/Then
        XCTAssertFalse(RecurringTaskGenerator.isRecurring(task))
    }
}
