////
//	HabitPet
//	PersistenceController.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

final class PersistenceController: @unchecked Sendable {
	let container: NSPersistentContainer

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "HabitPet")

		if inMemory {
			let description = NSPersistentStoreDescription()
			description.type = NSInMemoryStoreType
			description.shouldAddStoreAsynchronously = false
			container.persistentStoreDescriptions = [description]
		}

		container.loadPersistentStores { _, error in
			if let error {
				fatalError("Failed to load persistent stores: \(error)")
			}
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
	}

	func newBackgroundContext() -> NSManagedObjectContext {
		let context = container.newBackgroundContext()
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return context
	}
}
