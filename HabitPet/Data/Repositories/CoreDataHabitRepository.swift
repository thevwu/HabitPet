////
//	HabitPet
//	CoreDataHabitRepository.swift
//
//	Created by: thevwu on 2026
//
import CoreData
import Foundation

struct CoreDataHabitRepository: HabitRepository, Sendable {
	let persistence: PersistenceController

	func fetchHabits() async throws -> [Habit] {
		let context = persistence.newBackgroundContext()

		return try await context.performAsync { context in
			let request = HabitEntity.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
			let result = try context.fetch(request)
			return result.compactMap(HabitMapper.toDomain)
		}
	}

	func saveHabit(_ habit: Habit) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = HabitEntity.fetchRequest()
			request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
			request.fetchLimit = 1

			let entity = try context.fetch(request).first ?? HabitEntity(context: context)
			HabitMapper.upsert(habit, into: entity)
			try context.saveIfNeeded()
		}
	}

	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = HabitEntity.fetchRequest()
			request.fetchLimit = 1

			let existing = try context.fetch(request)
			guard existing.isEmpty else { return }

			let resolvedBootstrap = bootstrap ?? .default(now: now)
			let habits = HomeSeedFactory.makeHabits(from: resolvedBootstrap)

			for habit in habits {
				let entity = HabitEntity(context: context)
				HabitMapper.upsert(habit, into: entity)
			}

			try context.saveIfNeeded()
		}
	}
}
