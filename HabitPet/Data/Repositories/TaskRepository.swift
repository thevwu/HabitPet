////
//	HabitPet
//	TaskRepository.swift
//
//	Created by: thevwu on 2026
//

import Foundation

protocol TaskRepository: Sendable {
	func fetchTasks() async throws -> [TaskItem]
	func saveTask(_ task: TaskItem) async throws
	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws
}
