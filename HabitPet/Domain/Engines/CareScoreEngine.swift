////
//	HabitPet
//	CareScoreEngine.swift
//
//	Created by: thevwu on 2026
//

import Foundation

enum CareScoreEngine {
	static func calculate(
		completedHabits: Int,
		totalHabits: Int,
		completedTasks: Int,
		totalTasks: Int
	) -> Int {
		let habitScore: Double = totalHabits == 0 ? 0 : Double(completedHabits) / Double(totalHabits)
		let taskScore: Double = totalTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)

		let weighted = (habitScore * 0.7) + (taskScore * 0.3)
		return Int((weighted * 100).rounded())
	}
}
