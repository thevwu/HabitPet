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
}
