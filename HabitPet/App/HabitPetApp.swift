////
//	HabitPet
//	AppFeature.swift
//
//	Created by: thevwu on 2026
//

import SwiftUI
import ComposableArchitecture

@main
struct HabitPetApp: App {
	private let persistence = PersistenceController()

	var body: some Scene {
		WindowGroup {
			AppView(
				store: Store(initialState: AppFeature.State()) {
					AppFeature()
				} withDependencies: {
					let petRepo = CoreDataPetRepository(persistence: persistence)
					let habitRepo = CoreDataHabitRepository(persistence: persistence)
					let taskRepo = CoreDataTaskRepository(persistence: persistence)
					let completionRepo = CoreDataCompletionEventRepository(persistence: persistence)

					$0.petRepository = PetRepositoryClient(
						fetchPet: { try await petRepo.fetchPet() },
						savePet: { try await petRepo.savePet($0) },
						seedIfNeeded: { now, bootstrap in
							try await petRepo.seedIfNeeded(now: now, bootstrap: bootstrap)
						}
					)

					$0.habitRepository = HabitRepositoryClient(
						fetchHabits: { try await habitRepo.fetchHabits() },
						saveHabit: { try await habitRepo.saveHabit($0) },
						seedIfNeeded: { now, bootstrap in
							try await habitRepo.seedIfNeeded(now: now, bootstrap: bootstrap)
						}
					)

					$0.taskRepository = TaskRepositoryClient(
						fetchTasks: { try await taskRepo.fetchTasks() },
						saveTask: { try await taskRepo.saveTask($0) },
						seedIfNeeded: { now, bootstrap in
							try await taskRepo.seedIfNeeded(now: now, bootstrap: bootstrap)
						}
					)

					$0.completionEventRepository = CompletionEventRepositoryClient(
						fetchEventsForDay: { try await completionRepo.fetchEvents(forDayContaining: $0) },
						append: { try await completionRepo.append($0) }
					)
				}
			)
		}
	}
}
