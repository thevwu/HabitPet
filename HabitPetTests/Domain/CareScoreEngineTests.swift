////
//	HabitPet
//	CareScoreEngineTests.swift
//
//	Created by: thevwu on 2026
//

import XCTest
@testable import HabitPet

final class CareScoreEngineTests: XCTestCase {
	func testCalculateReturnsZeroWhenNothingCompleted() {
		let score = CareScoreEngine.calculate(
			completedHabits: 0,
			totalHabits: 3,
			completedTasks: 0,
			totalTasks: 2
		)

		XCTAssertEqual(score, 0)
	}

	func testCalculateReturnsHundredWhenEverythingCompleted() {
		let score = CareScoreEngine.calculate(
			completedHabits: 3,
			totalHabits: 3,
			completedTasks: 2,
			totalTasks: 2
		)

		XCTAssertEqual(score, 100)
	}

	func testCalculateUsesHabitWeightedFormula() {
		let score = CareScoreEngine.calculate(
			completedHabits: 2,
			totalHabits: 4,
			completedTasks: 1,
			totalTasks: 4
		)

		// habits = 0.5, tasks = 0.25
		// weighted = (0.5 * 0.7) + (0.25 * 0.3) = 0.425
		// rounded to Int = 43
		XCTAssertEqual(score, 43)
	}

	func testCalculateHandlesZeroTotalsSafely() {
		let score = CareScoreEngine.calculate(
			completedHabits: 0,
			totalHabits: 0,
			completedTasks: 0,
			totalTasks: 0
		)

		XCTAssertEqual(score, 0)
	}
}
