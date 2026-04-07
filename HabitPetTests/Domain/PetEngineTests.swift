////
//	HabitPet
//	PetEngineTests.swift
//
//	Created by: thevwu on 2026
//

import Testing
@testable import HabitPet

struct PetEngineTests {
	@Test
	func becomesJoyfulWithStrongCompletionAndLowOverload() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 3,
			completedTasks: 1,
			overload: .light
		)

		#expect(updated.mood == .joyful)
		#expect(updated.energy > pet.energy)
		#expect(updated.affection > pet.affection)
	}

	@Test
	func becomesWorriedWhenNothingCompletedAndLoadIsHeavy() {
		let pet = TestFixtures.pet()

		let updated = PetEngine.updatePet(
			current: pet,
			completedHabits: 0,
			completedTasks: 0,
			overload: .heavy
		)

		#expect(updated.mood == .worried)
		#expect(updated.energy < pet.energy)
		#expect(updated.affection < pet.affection)
	}
}
