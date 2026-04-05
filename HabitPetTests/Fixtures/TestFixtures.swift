////
//	HabitPet
//	TestFixtures.swift
//
//	Created by: thevwu on 2026
//

import Foundation
import ComposableArchitecture
@testable import HabitPet

enum TestFixtures {
	static let petID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!

	static let drinkWaterID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
	static let runID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
	static let readID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

	static let recruiterID = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
	static let resumeID = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!

	static func pet(
		mood: PetMood = .neutral,
		energy: Int = 65,
		affection: Int = 60
	) -> Pet {
		Pet(
			id: petID,
			name: "Mochi",
			type: .dog,
			mood: mood,
			energy: energy,
			affection: affection
		)
	}

	static func habits(
		drinkWaterCompleted: Bool = false,
		runCompleted: Bool = false,
		readCompleted: Bool = false
	) -> IdentifiedArrayOf<Habit> {
		IdentifiedArray(
			uniqueElements: [
				Habit(id: drinkWaterID, title: "Drink water", effort: 1, isCompletedToday: drinkWaterCompleted),
				Habit(id: runID, title: "Go for a run", effort: 3, isCompletedToday: runCompleted),
				Habit(id: readID, title: "Read 20 minutes", effort: 2, isCompletedToday: readCompleted)
			]
		)
	}

	static func tasks(
		recruiterCompleted: Bool = false,
		resumeCompleted: Bool = false
	) -> IdentifiedArrayOf<TaskItem> {
		IdentifiedArray(
			uniqueElements: [
				TaskItem(id: recruiterID, title: "Reply to recruiter", effort: 2, isCompleted: recruiterCompleted),
				TaskItem(id: resumeID, title: "Review resume bullets", effort: 2, isCompleted: resumeCompleted)
			]
		)
	}

	static func homeState(
		pet: Pet = pet(),
		habits: IdentifiedArrayOf<Habit> = habits(),
		tasks: IdentifiedArrayOf<TaskItem> = tasks(),
		careScore: Int = 72,
		overload: BurnoutLevel = .light,
		message: String = "Your pet is waiting to see how today goes."
	) -> HomeFeature.State {
		HomeFeature.State(
			pet: pet,
			habits: habits,
			tasks: tasks,
			careScore: careScore,
			overloadLevel: overload,
			message: message
		)
	}
}
