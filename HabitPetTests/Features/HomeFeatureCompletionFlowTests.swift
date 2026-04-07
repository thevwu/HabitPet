////
//	HabitPet
//	HomeFeatureCompletionFlowTests.swift
//
//	Created by: thevwu on 2026
//

import Foundation
import Testing
import ComposableArchitecture
@testable import HabitPet

struct HomeFeatureCompletionFlowTests {
	@Test
	func completingHabitPersistsAndAppendsEvent() async throws {
		let now = TestFixtures.fixedNow

		let pet = TestFixtures.pet()
		let habit = TestFixtures.habit(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000777")!,
			title: "Morning walk",
			effort: 3,
			isCompletedToday: false
		)
		let tasks = TestFixtures.tasks()

		let currentPet = LockIsolated(pet)
		let currentHabits = LockIsolated([habit])
		let currentTasks = LockIsolated(tasks)
		let currentEvents = LockIsolated([CompletionEvent]())

		let savedHabits = LockIsolated([Habit]())
		let appendedEvents = LockIsolated([CompletionEvent]())

		let completionEventID = UUID(uuidString: "00000000-0000-0000-0000-00000000E001")!

		let initialOverload = BurnoutEngine.evaluate(
			habits: [habit],
			tasks: tasks
		)
		let initialPet = PetEngine.updatePet(
			current: pet,
			completedHabits: 0,
			completedTasks: tasks.filter(\.isCompleted).count,
			overload: initialOverload
		)
		let initialCareScore = CareScoreEngine.calculate(
			completedHabits: 0,
			totalHabits: 1,
			completedTasks: tasks.filter(\.isCompleted).count,
			totalTasks: tasks.count
		)
		let initialMessage = PetEngine.message(
			for: initialPet,
			totalCompleted: tasks.filter(\.isCompleted).count,
			overload: initialOverload
		)

		let initialState = HomeFeature.State(
			pet: initialPet,
			habits: IdentifiedArray(uniqueElements: [habit]),
			tasks: IdentifiedArray(uniqueElements: tasks),
			careScore: initialCareScore,
			overloadLevel: initialOverload,
			message: initialMessage,
			isLoading: false,
			errorMessage: nil,
			bootstrap: nil
		)

		let store = await TestStore(initialState: initialState) {
			HomeFeature()
		} withDependencies: {
			$0.dateProvider.now = { now }
			$0.uuidProvider.make = { completionEventID }

			$0.petRepository.seedIfNeeded = { _, _ in }
			$0.petRepository.fetchPet = { currentPet.value }
			$0.petRepository.savePet = { updated in
				currentPet.setValue(updated)
			}

			$0.habitRepository.seedIfNeeded = { _, _ in }
			$0.habitRepository.fetchHabits = { currentHabits.value }
			$0.habitRepository.saveHabit = { updated in
				currentHabits.withValue { habits in
					guard let index = habits.firstIndex(where: { $0.id == updated.id }) else {
						habits.append(updated)
						return
					}
					habits[index] = updated
				}
				savedHabits.withValue { $0.append(updated) }
			}

			$0.taskRepository.seedIfNeeded = { _, _ in }
			$0.taskRepository.fetchTasks = { currentTasks.value }
			$0.taskRepository.saveTask = { updated in
				currentTasks.withValue { tasks in
					guard let index = tasks.firstIndex(where: { $0.id == updated.id }) else {
						tasks.append(updated)
						return
					}
					tasks[index] = updated
				}
			}

			$0.completionEventRepository.fetchEventsForDay = { _ in
				currentEvents.value
			}
			$0.completionEventRepository.append = { event in
				currentEvents.withValue { $0.append(event) }
				appendedEvents.withValue { $0.append(event) }
			}
		}

		let expectedUpdatedHabit = Habit(
			id: habit.id,
			title: habit.title,
			effort: habit.effort,
			isCompletedToday: true,
			syncMetadata: SyncMetadata(
				createdAt: habit.syncMetadata.createdAt,
				updatedAt: now,
				deletedAt: habit.syncMetadata.deletedAt,
				syncStatus: .pendingUpdate,
				serverUpdatedAt: habit.syncMetadata.serverUpdatedAt,
				originDeviceID: habit.syncMetadata.originDeviceID
			)
		)

		let expectedHabits = [expectedUpdatedHabit]
		let expectedTasks = tasks
		let expectedOverload = BurnoutEngine.evaluate(
			habits: expectedHabits,
			tasks: expectedTasks
		)
		let expectedPet = PetEngine.updatePet(
			current: pet,
			completedHabits: 1,
			completedTasks: expectedTasks.filter(\.isCompleted).count,
			overload: expectedOverload
		)
		let expectedCareScore = CareScoreEngine.calculate(
			completedHabits: 1,
			totalHabits: expectedHabits.count,
			completedTasks: expectedTasks.filter(\.isCompleted).count,
			totalTasks: expectedTasks.count
		)
		let expectedMessage = PetEngine.message(
			for: expectedPet,
			totalCompleted: 1 + expectedTasks.filter(\.isCompleted).count,
			overload: expectedOverload
		)

		await store.send(.habitCompleteTapped(habit.id)) {
			$0.isLoading = true
			$0.errorMessage = nil
		}

		await store.receive(.completionResponse(.success(
			HomeFeature.LoadPayload(
				pet: pet,
				habits: expectedHabits,
				tasks: expectedTasks,
				events: [
					CompletionEvent(
						id: completionEventID,
						itemID: habit.id,
						itemType: .habit,
						completedAt: now,
						effort: habit.effort,
						syncMetadata: .fresh(now: now)
					)
				]
			)
		))) {
			$0.isLoading = false
			$0.errorMessage = nil
			$0.pet = expectedPet
			$0.habits = IdentifiedArray(uniqueElements: expectedHabits)
			$0.tasks = IdentifiedArray(uniqueElements: expectedTasks)
			$0.overloadLevel = expectedOverload
			$0.careScore = expectedCareScore
			$0.message = expectedMessage
		}

		#expect(savedHabits.value.count == 1)
		#expect(savedHabits.value.first == expectedUpdatedHabit)

		#expect(currentHabits.value == expectedHabits)

		#expect(appendedEvents.value.count == 1)
		#expect(appendedEvents.value.first?.id == completionEventID)
		#expect(appendedEvents.value.first?.itemID == habit.id)
		#expect(appendedEvents.value.first?.itemType == .habit)
		#expect(appendedEvents.value.first?.effort == habit.effort)
		#expect(appendedEvents.value.first?.completedAt == now)

		#expect(currentEvents.value.count == 1)
	}
}
