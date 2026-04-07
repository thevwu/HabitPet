////
//	HabitPet
//	HabitRepository.swift
//
//	Created by: thevwu on 2026
//

import Foundation

protocol HabitRepository: Sendable {
	func fetchHabits() async throws -> [Habit]
	func saveHabit(_ habit: Habit) async throws
	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws
}
