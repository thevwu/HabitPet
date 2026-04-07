////
//	HabitPet
//	CareScoreEngineTests.swift
//
//	Created by: thevwu on 2026
//

import Testing
@testable import HabitPet

struct CareScoreEngineTests {
	@Test
	func calculatesWeightedScore() {
		let score = CareScoreEngine.calculate(
			completedHabits: 2,
			totalHabits: 4,
			completedTasks: 1,
			totalTasks: 2
		)

		#expect(score == 50)
	}

	@Test
	func returnsZeroWhenNothingCompleted() {
		let score = CareScoreEngine.calculate(
			completedHabits: 0,
			totalHabits: 3,
			completedTasks: 0,
			totalTasks: 2
		)

		#expect(score == 0)
	}

	@Test
	func returnsHundredWhenEverythingCompleted() {
		let score = CareScoreEngine.calculate(
			completedHabits: 3,
			totalHabits: 3,
			completedTasks: 2,
			totalTasks: 2
		)

		#expect(score == 100)
	}
}
