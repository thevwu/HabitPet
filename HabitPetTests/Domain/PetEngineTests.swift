////
//	HabitPet
//	PetEngineTests.swift
//
//	Created by: thevwu on 2026
//

import XCTest
@testable import HabitPet

final class PetEngineTests: XCTestCase {
	func testUpdatePetBecomesJoyfulOnStrongCompletionAndLowOverload() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 3,
			completedTasks: 1,
			overload: .light
		)

		XCTAssertEqual(updated.mood, .joyful)
		XCTAssertEqual(updated.energy, 80)
		XCTAssertEqual(updated.affection, 72)
	}

	func testUpdatePetBecomesEnergeticOnModerateCompletion() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 1,
			completedTasks: 1,
			overload: .none
		)

		XCTAssertEqual(updated.mood, .energetic)
		XCTAssertEqual(updated.energy, 73)
		XCTAssertEqual(updated.affection, 66)
	}

	func testUpdatePetBecomesWorriedWhenNothingDoneAndOverloadIsHeavy() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 0,
			completedTasks: 0,
			overload: .heavy
		)

		XCTAssertEqual(updated.mood, .worried)
		XCTAssertEqual(updated.energy, 57)
		XCTAssertEqual(updated.affection, 54)
	}

	func testUpdatePetBecomesSleepyWhenNothingDoneWithoutHeavyOverload() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 0,
			completedTasks: 0,
			overload: .light
		)

		XCTAssertEqual(updated.mood, .sleepy)
		XCTAssertEqual(updated.energy, 61)
		XCTAssertEqual(updated.affection, 58)
	}

	func testMessageReturnsOverloadMessageWhenHeavy() {
		let message = PetEngine.message(
			for: TestFixtures.pet(),
			totalCompleted: 2,
			overload: .heavy
		)

		XCTAssertTrue(message.contains("overloaded"))
	}

	func testMessageReturnsThrivingMessageWhenManyItemsCompleted() {
		let message = PetEngine.message(
			for: TestFixtures.pet(),
			totalCompleted: 4,
			overload: .none
		)

		XCTAssertEqual(message, "Mochi is thriving today.")
	}
}
