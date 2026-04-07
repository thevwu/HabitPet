////
//	HabitPet
//	CoreDataPetRepository.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

struct CoreDataPetRepository: PetRepository, Sendable {
	let persistence: PersistenceController

	func fetchPet() async throws -> Pet? {
		let context = persistence.newBackgroundContext()

		return try await context.performAsync { context in
			let request = PetEntity.fetchRequest()
			request.fetchLimit = 1
			let result = try context.fetch(request)
			guard let entity = result.first else { return nil }
			return PetMapper.toDomain(entity)
		}
	}

	func savePet(_ pet: Pet) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = PetEntity.fetchRequest()
			request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
			request.fetchLimit = 1

			let entity = try context.fetch(request).first ?? PetEntity(context: context)
			PetMapper.upsert(pet, into: entity)
			try context.saveIfNeeded()
		}
	}

	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws {
		let context = persistence.newBackgroundContext()

		try await context.performAsync { context in
			let request = PetEntity.fetchRequest()
			request.fetchLimit = 1

			let existing = try context.fetch(request)
			guard existing.isEmpty else { return }

			let resolvedBootstrap = bootstrap ?? .default(now: now)
			let pet = HomeSeedFactory.makePet(from: resolvedBootstrap, now: now)

			let entity = PetEntity(context: context)
			PetMapper.upsert(pet, into: entity)

			try context.saveIfNeeded()
		}
	}
}
