////
//	HabitPet
//	TaskItem.swift
//
//	Created by: thevwu on 2026
//

import Foundation

struct TaskItem: Equatable, Identifiable, Sendable {
	let id: UUID
	var title: String
	var effort: Int
	var isCompleted: Bool
	var syncMetadata: SyncMetadata

	static func seeds(now: Date) -> [TaskItem] {
		[
			TaskItem(id: UUID(), title: "Reply to recruiter", effort: 2, isCompleted: false, syncMetadata: .fresh(now: now)),
			TaskItem(id: UUID(), title: "Review resume bullets", effort: 2, isCompleted: false, syncMetadata: .fresh(now: now))
		]
	}
}
