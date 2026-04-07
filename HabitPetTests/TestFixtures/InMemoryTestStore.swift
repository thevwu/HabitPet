////
//	HabitPet
//	InMemoryTestStore.swift
//
//	Created by: thevwu on 2026
//


import Foundation
@testable import HabitPet

enum InMemoryTestStore {
    static func makePersistenceController() -> PersistenceController {
        PersistenceController(inMemory: true)
    }

    static func makeRepositories(
        persistence: PersistenceController
    ) -> (
        pet: CoreDataPetRepository,
        habit: CoreDataHabitRepository,
        task: CoreDataTaskRepository,
        completion: CoreDataCompletionEventRepository
    ) {
        (
            pet: CoreDataPetRepository(persistence: persistence),
            habit: CoreDataHabitRepository(persistence: persistence),
            task: CoreDataTaskRepository(persistence: persistence),
            completion: CoreDataCompletionEventRepository(persistence: persistence)
        )
    }
}