////
//	HabitPet
//	CoreDataTaskRepository.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

struct CoreDataTaskRepository: TaskRepository, Sendable {
	let persistence: PersistenceController

	func fetchTasks() async throws -> [TaskItem] {
		let context = persistence.newBackgroundContext()

		return try await context.performAsync { context in
			let request = TaskItemEntity.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
			let result = try context.fetch(request)
			return result.compactMap(TaskItemMapper.toDomain)
		}
	}

	func saveTask(_ task: TaskItem) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = TaskItemEntity.fetchRequest()
			request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
			request.fetchLimit = 1

			let entity = try context.fetch(request).first ?? TaskItemEntity(context: context)
			TaskItemMapper.upsert(task, into: entity)
			try context.saveIfNeeded()
		}
	}

	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = TaskItemEntity.fetchRequest()
			request.fetchLimit = 1

			let existing = try context.fetch(request)
			guard existing.isEmpty else { return }

			let tasks = HomeSeedFactory.makeTasks(now: now)

			for task in tasks {
				let entity = TaskItemEntity(context: context)
				TaskItemMapper.upsert(task, into: entity)
			}

			try context.saveIfNeeded()
		}
	}
}
