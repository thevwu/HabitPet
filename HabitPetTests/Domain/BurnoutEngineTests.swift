////
//	HabitPet
//	BurnoutEngineTests.swift
//
//	Created by: thevwu on 2026
//

import Testing
@testable import HabitPet

struct BurnoutEngineTests {
	@Test
	func returnsNoneForLowEffortLoad() {
		let habits = [
			TestFixtures.habit(title: "Water", effort: 1),
			TestFixtures.habit(title: "Walk", effort: 2)
		]
		let tasks = [
			TestFixtures.task(title: "Email", effort: 2)
		]

		#expect(BurnoutEngine.evaluate(habits: habits, tasks: tasks) == .none)
	}

	@Test
	func returnsLightForMediumEffortLoad() {
		let habits = [
			TestFixtures.habit(title: "Run", effort: 3),
			TestFixtures.habit(title: "Read", effort: 2)
		]
		let tasks = [
			TestFixtures.task(title: "Admin", effort: 2),
			TestFixtures.task(title: "Plan", effort: 1)
		]

		#expect(BurnoutEngine.evaluate(habits: habits, tasks: tasks) == .light)
	}

	@Test
	func returnsHeavyForLargeEffortLoad() {
		let habits = [
			TestFixtures.habit(title: "Run", effort: 4),
			TestFixtures.habit(title: "Study", effort: 4)
		]
		let tasks = [
			TestFixtures.task(title: "Interview prep", effort: 4)
		]

		#expect(BurnoutEngine.evaluate(habits: habits, tasks: tasks) == .heavy)
	}
}
