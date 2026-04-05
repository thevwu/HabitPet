////
//	HabitPet
//	Habit.swift
//
//	Created by: thevwu on 2026
//

import Foundation

struct Habit: Equatable, Identifiable {
	let id: UUID
	var title: String
	var effort: Int
	var isCompletedToday: Bool

	static let sampleHabits: [Habit] = [
		Habit(id: UUID(), title: "Drink water", effort: 1, isCompletedToday: false),
		Habit(id: UUID(), title: "Go for a run", effort: 3, isCompletedToday: false),
		Habit(id: UUID(), title: "Read 20 minutes", effort: 2, isCompletedToday: false)
	]
}
