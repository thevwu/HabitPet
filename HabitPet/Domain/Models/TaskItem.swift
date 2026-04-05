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
}
