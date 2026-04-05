////
//	HabitPet
//	BurnoutEngineTests.swift
//
//	Created by: thevwu on 2026
//

import XCTest
@testable import HabitPet

final class BurnoutEngineTests: XCTestCase {
	func testEvaluateReturnsNoneForLowEffortDay() {
		let habits = [
			Habit(id: UUID(), title: "Water", effort: 1, isCompletedToday: false),
			Habit(id: UUID(), title: "Walk", effort: 2, isCompletedToday: false)
		]
		let tasks = [
			TaskItem(id: UUID(), title: "Email", effort: 2, isCompleted: false)
		]

		let result = BurnoutEngine.evaluate(habits: habits, tasks: tasks)

		XCTAssertEqual(result, .none)
	}

	func testEvaluateReturnsLightForModerateEffortDay() {
		let habits = [
			Habit(id: UUID(), title: "Run", effort: 3, isCompletedToday: false),
			Habit(id: UUID(), title: "Read", effort: 2, isCompletedToday: false)
		]
		let tasks = [
			TaskItem(id: UUID(), title: "Prep", effort: 2, isCompleted: false),
			TaskItem(id: UUID(), title: "Review", effort: 1, isCompleted: false)
		]

		let result = BurnoutEngine.evaluate(habits: habits, tasks: tasks)

		XCTAssertEqual(result, .light)
	}

	func testEvaluateReturnsHeavyForHighEffortDay() {
		let habits = [
			Habit(id: UUID(), title: "Long Run", effort: 4, isCompletedToday: false),
			Habit(id: UUID(), title: "Deep Work", effort: 4, isCompletedToday: false)
		]
		let tasks = [
			TaskItem(id: UUID(), title: "Interview Prep", effort: 3, isCompleted: false)
		]

		let result = BurnoutEngine.evaluate(habits: habits, tasks: tasks)

		XCTAssertEqual(result, .heavy)
	}
}
