////
//	HabitPet
//	TaskItem.swift
//
//	Created by: thevwu on 2026
//

import Foundation

struct TaskItem: Equatable, Identifiable {
	let id: UUID
	var title: String
	var effort: Int
	var isCompleted: Bool

	static let sampleTasks: [TaskItem] = [
		TaskItem(id: UUID(), title: "Reply to recruiter", effort: 2, isCompleted: false),
		TaskItem(id: UUID(), title: "Review resume bullets", effort: 2, isCompleted: false)
	]
}
