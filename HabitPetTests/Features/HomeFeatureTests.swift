////
//	HabitPet
//	HomeFeatureTests.swift
//
//	Created by: thevwu on 2026
//


import Foundation
import Testing
import ComposableArchitecture
@testable import HabitPet

struct HomeFeatureTests {
    @Test
    func loadSeedsAndLoadsHome() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let pet = Pet.seeds(now: now)
        let habits = Habit.seeds(now: now)
        let tasks = TaskItem.seeds(now: now)

		let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.dateProvider.now = { now }
            $0.petRepository.fetchPet = { pet }
            $0.petRepository.seedIfNeeded = { _,_ in }
            $0.habitRepository.fetchHabits = { habits }
            $0.habitRepository.seedIfNeeded = { _,_ in }
            $0.taskRepository.fetchTasks = { tasks }
            $0.taskRepository.seedIfNeeded = { _,_ in }
            $0.completionEventRepository.fetchEventsForDay = { _ in [] }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(\.loadResponse.success) {
            $0.isLoading = false
			$0.sourcePet = pet
            $0.pet = PetEngine.updatePet(
                current: pet,
                completedHabits: 0,
                completedTasks: 0,
                overload: BurnoutEngine.evaluate(habits: habits, tasks: tasks)
            )
            $0.habits = IdentifiedArray(uniqueElements: habits)
            $0.tasks = IdentifiedArray(uniqueElements: tasks)
            $0.overloadLevel = BurnoutEngine.evaluate(habits: habits, tasks: tasks)
            $0.careScore = 0
            $0.message = "\(pet.name) is waiting for your first completed task."
        }
    }
}
