////
//	HabitPet
//	PetEngine.swift
//
//	Created by: thevwu on 2026
//

import Foundation

enum PetEngine {
	static func updatePet(
		current: Pet,
		completedHabits: Int,
		completedTasks: Int,
		overload: BurnoutLevel
	) -> Pet {
		var pet = current
		let totalCompleted = completedHabits + completedTasks

		switch (totalCompleted, overload) {
		case (4..., .none), (4..., .light):
			pet.mood = .joyful
			pet.energy = min(pet.energy + 15, 100)
			pet.affection = min(pet.affection + 12, 100)

		case (2..., .none), (2..., .light):
			pet.mood = .energetic
			pet.energy = min(pet.energy + 8, 100)
			pet.affection = min(pet.affection + 6, 100)

		case (0, .heavy):
			pet.mood = .worried
			pet.energy = max(pet.energy - 8, 0)
			pet.affection = max(pet.affection - 6, 0)

		case (0, _):
			pet.mood = .sleepy
			pet.energy = max(pet.energy - 4, 0)
			pet.affection = max(pet.affection - 2, 0)

		default:
			pet.mood = .neutral
		}

		return pet
	}

	static func message(
		for pet: Pet,
		totalCompleted: Int,
		overload: BurnoutLevel
	) -> String {
		if overload == .heavy {
			return "\(pet.name) thinks today may be overloaded. Focus on one important win."
		}

		switch totalCompleted {
		case 0:
			return "\(pet.name) is waiting for your first completed task."
		case 1:
			return "\(pet.name) noticed your progress. Keep going."
		case 2...3:
			return "\(pet.name) is getting excited. Momentum is building."
		default:
			return "\(pet.name) is thriving today."
		}
	}
}
