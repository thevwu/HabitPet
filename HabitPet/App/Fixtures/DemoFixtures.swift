////
//	HabitPet
//	DemoFixtures.swift
//
//	Created by: thevwu on 2026
//

import Foundation
import ComposableArchitecture

enum DemoFixtures {
	static let petID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!

	static let drinkWaterID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
	static let runID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
	static let readID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

	static let recruiterID = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
	static let resumeID = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!

	static let pet = Pet(
		id: petID,
		name: "Mochi",
		type: .dog,
		mood: .neutral,
		energy: 65,
		affection: 60
	)

	static let habits = IdentifiedArray(
		uniqueElements: [
			Habit(id: drinkWaterID, title: "Drink water", effort: 1, isCompletedToday: false),
			Habit(id: runID, title: "Go for a run", effort: 3, isCompletedToday: false),
			Habit(id: readID, title: "Read 20 minutes", effort: 2, isCompletedToday: false)
		]
	)

	static let tasks = IdentifiedArray(
		uniqueElements: [
			TaskItem(id: recruiterID, title: "Reply to recruiter", effort: 2, isCompleted: false),
			TaskItem(id: resumeID, title: "Review resume bullets", effort: 2, isCompleted: false)
		]
	)
}
