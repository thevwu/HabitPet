////
//  HabitPet
//  HomeFeatureCompletionTests.swift
//
//  Created by: thevwu on 2026
//

import Foundation
import Testing
import ComposableArchitecture
@testable import HabitPet

struct HomeFeatureCompletionTests {
	@Test
	func completingHabitReconcilesLocallyAndAppendsEvent() async throws {
		let now = TestFixtures.fixedNow

		let pet = TestFixtures.pet()
		let habit = TestFixtures.habit(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000777")!,
			title: "Morning walk",
			effort: 3,
			isCompletedToday: false
		)
		let tasks = TestFixtures.tasks()

		let fetchPetCount = LockIsolated(0)
		let fetchHabitCount = LockIsolated(0)
		let fetchTaskCount = LockIsolated(0)
		let fetchEventCount = LockIsolated(0)

		let currentPet = LockIsolated(pet)
		let currentHabits = LockIsolated([habit])
		let currentTasks = LockIsolated(tasks)
		let currentEvents = LockIsolated([CompletionEvent]())

		let savedHabits = LockIsolated([Habit]())
		let appendedEvents = LockIsolated([CompletionEvent]())

		let completionEventID = UUID(uuidString: "00000000-0000-0000-0000-00000000E001")!
		let initialState = makeLoadedState(pet: pet, habits: [habit], tasks: tasks)

		let store = await TestStore(initialState: initialState) {
			HomeFeature()
		} withDependencies: {
			$0.dateProvider.now = { now }
			$0.uuidProvider.make = { completionEventID }

			$0.petRepository.seedIfNeeded = { _, _ in }
			$0.petRepository.fetchPet = {
				fetchPetCount.withValue { $0 += 1 }
				return currentPet.value
			}
			$0.petRepository.savePet = { updated in
				currentPet.setValue(updated)
			}

			$0.habitRepository.seedIfNeeded = { _, _ in }
			$0.habitRepository.fetchHabits = {
				fetchHabitCount.withValue { $0 += 1 }
				return currentHabits.value
			}
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
			$0.taskRepository.fetchTasks = {
				fetchTaskCount.withValue { $0 += 1 }
				return currentTasks.value
			}
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
				fetchEventCount.withValue { $0 += 1 }
				return currentEvents.value
			}
			$0.completionEventRepository.append = { event in
				currentEvents.withValue { $0.append(event) }
				appendedEvents.withValue { $0.append(event) }
			}
		}

		let expectedUpdatedHabit = completedHabit(from: habit, now: now)
		let expectedEvent = TestFixtures.completionEvent(
			id: completionEventID,
			itemID: habit.id,
			itemType: .habit,
			completedAt: now,
			effort: habit.effort,
			syncMetadata: .fresh(now: now)
		)
		let expectedState = makeLoadedState(pet: pet, habits: [expectedUpdatedHabit], tasks: tasks)

		await store.send(.habitCompleteTapped(habit.id)) {
			$0.errorMessage = nil
			$0.completingHabitIDs = [habit.id]
		}

		await store.receive(
			.completionResponse(
				.habit(habit.id),
				.success(
					HomeFeature.CompletionOutcome(
						target: .habit(expectedUpdatedHabit),
						event: expectedEvent
					)
				)
			)
		) {
			$0.errorMessage = nil
			$0.completingHabitIDs = []
			$0.pet = expectedState.pet
			$0.sourcePet = expectedState.sourcePet
			$0.habits = expectedState.habits
			$0.tasks = expectedState.tasks
			$0.careScore = expectedState.careScore
			$0.overloadLevel = expectedState.overloadLevel
			$0.message = expectedState.message
		}

		#expect(fetchPetCount.value == 0)
		#expect(fetchHabitCount.value == 0)
		#expect(fetchTaskCount.value == 0)
		#expect(fetchEventCount.value == 0)

		#expect(savedHabits.value == [expectedUpdatedHabit])
		#expect(currentHabits.value == [expectedUpdatedHabit])

		#expect(appendedEvents.value == [expectedEvent])
		#expect(currentEvents.value == [expectedEvent])
	}

	@Test
	func completingTaskReconcilesLocallyAndAppendsEvent() async throws {
		let now = TestFixtures.fixedNow

		let pet = TestFixtures.pet()
		let habits = TestFixtures.habits()
		let task = TestFixtures.task(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000888")!,
			title: "Send follow-up",
			effort: 2,
			isCompleted: false
		)

		let savedTasks = LockIsolated([TaskItem]())
		let appendedEvents = LockIsolated([CompletionEvent]())

		let completionEventID = UUID(uuidString: "00000000-0000-0000-0000-00000000E002")!
		let initialState = makeLoadedState(pet: pet, habits: habits, tasks: [task])

		let store = await TestStore(initialState: initialState) {
			HomeFeature()
		} withDependencies: {
			$0.dateProvider.now = { now }
			$0.uuidProvider.make = { completionEventID }

			$0.petRepository.seedIfNeeded = { _, _ in }
			$0.petRepository.fetchPet = { pet }
			$0.petRepository.savePet = { _ in }

			$0.habitRepository.seedIfNeeded = { _, _ in }
			$0.habitRepository.fetchHabits = { habits }
			$0.habitRepository.saveHabit = { _ in }

			$0.taskRepository.seedIfNeeded = { _, _ in }
			$0.taskRepository.fetchTasks = { [task] }
			$0.taskRepository.saveTask = { updated in
				savedTasks.withValue { $0.append(updated) }
			}

			$0.completionEventRepository.fetchEventsForDay = { _ in [] }
			$0.completionEventRepository.append = { event in
				appendedEvents.withValue { $0.append(event) }
			}
		}

		let expectedUpdatedTask = completedTask(from: task, now: now)
		let expectedEvent = TestFixtures.completionEvent(
			id: completionEventID,
			itemID: task.id,
			itemType: .task,
			completedAt: now,
			effort: task.effort,
			syncMetadata: .fresh(now: now)
		)
		let expectedState = makeLoadedState(pet: pet, habits: habits, tasks: [expectedUpdatedTask])

		await store.send(.taskCompleteTapped(task.id)) {
			$0.errorMessage = nil
			$0.completingTaskIDs = [task.id]
		}

		await store.receive(
			.completionResponse(
				.task(task.id),
				.success(
					HomeFeature.CompletionOutcome(
						target: .task(expectedUpdatedTask),
						event: expectedEvent
					)
				)
			)
		) {
			$0.errorMessage = nil
			$0.completingTaskIDs = []
			$0.pet = expectedState.pet
			$0.sourcePet = expectedState.sourcePet
			$0.habits = expectedState.habits
			$0.tasks = expectedState.tasks
			$0.careScore = expectedState.careScore
			$0.overloadLevel = expectedState.overloadLevel
			$0.message = expectedState.message
		}

		#expect(savedTasks.value == [expectedUpdatedTask])
		#expect(appendedEvents.value == [expectedEvent])
	}

	@Test
	func secondSameDayHabitTapIsNoOp() async throws {
		let pet = TestFixtures.pet()
		let completedHabit = TestFixtures.habit(
			title: "Drink water",
			effort: 1,
			isCompletedToday: true
		)
		let tasks = TestFixtures.tasks()

		let saveCount = LockIsolated(0)
		let appendCount = LockIsolated(0)

		let store = await TestStore(
			initialState: makeLoadedState(pet: pet, habits: [completedHabit], tasks: tasks)
		) {
			HomeFeature()
		} withDependencies: {
			$0.habitRepository.saveHabit = { _ in
				saveCount.withValue { $0 += 1 }
			}
			$0.completionEventRepository.append = { _ in
				appendCount.withValue { $0 += 1 }
			}
		}

		await store.send(.habitCompleteTapped(completedHabit.id))

		#expect(saveCount.value == 0)
		#expect(appendCount.value == 0)
	}

	@Test
	func inFlightHabitTapIsNoOp() async throws {
		let pet = TestFixtures.pet()
		let habit = TestFixtures.habit(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000889")!,
			title: "Read 10 pages",
			effort: 2,
			isCompletedToday: false
		)

		let saveCount = LockIsolated(0)
		let appendCount = LockIsolated(0)

		var state = makeLoadedState(pet: pet, habits: [habit], tasks: [])
		state.completingHabitIDs = [habit.id]

		let store = await TestStore(initialState: state) {
			HomeFeature()
		} withDependencies: {
			$0.habitRepository.saveHabit = { _ in
				saveCount.withValue { $0 += 1 }
			}
			$0.completionEventRepository.append = { _ in
				appendCount.withValue { $0 += 1 }
			}
		}

		await store.send(.habitCompleteTapped(habit.id))

		#expect(saveCount.value == 0)
		#expect(appendCount.value == 0)
	}

	@Test
	func completionEventRetrySucceedsBeforeReconcile() async throws {
		let now = TestFixtures.fixedNow

		let pet = TestFixtures.pet()
		let habit = TestFixtures.habit(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000901")!,
			title: "Meditate",
			effort: 2,
			isCompletedToday: false
		)

		let saveCount = LockIsolated(0)
		let appendCount = LockIsolated(0)
		let revertCount = LockIsolated(0)

		let completionEventID = UUID(uuidString: "00000000-0000-0000-0000-00000000E003")!
		let initialState = makeLoadedState(pet: pet, habits: [habit], tasks: [])

		let store = await TestStore(initialState: initialState) {
			HomeFeature()
		} withDependencies: {
			$0.dateProvider.now = { now }
			$0.uuidProvider.make = { completionEventID }

			$0.habitRepository.saveHabit = { updated in
				saveCount.withValue { $0 += 1 }
				if !updated.isCompletedToday {
					revertCount.withValue { $0 += 1 }
				}
			}

			$0.completionEventRepository.append = { _ in
				let current = appendCount.withValue {
					$0 += 1
					return $0
				}

				if current == 1 {
					throw AppError.repository(message: "Temporary append failure")
				}
			}
		}

		let expectedUpdatedHabit = completedHabit(from: habit, now: now)
		let expectedEvent = TestFixtures.completionEvent(
			id: completionEventID,
			itemID: habit.id,
			itemType: .habit,
			completedAt: now,
			effort: habit.effort,
			syncMetadata: .fresh(now: now)
		)
		let expectedState = makeLoadedState(pet: pet, habits: [expectedUpdatedHabit], tasks: [])

		await store.send(.habitCompleteTapped(habit.id)) {
			$0.errorMessage = nil
			$0.completingHabitIDs = [habit.id]
		}

		await store.receive(
			.completionResponse(
				.habit(habit.id),
				.success(
					HomeFeature.CompletionOutcome(
						target: .habit(expectedUpdatedHabit),
						event: expectedEvent
					)
				)
			)
		) {
			$0.errorMessage = nil
			$0.completingHabitIDs = []
			$0.pet = expectedState.pet
			$0.sourcePet = expectedState.sourcePet
			$0.habits = expectedState.habits
			$0.tasks = expectedState.tasks
			$0.careScore = expectedState.careScore
			$0.overloadLevel = expectedState.overloadLevel
			$0.message = expectedState.message
		}

		#expect(saveCount.value == 1)
		#expect(appendCount.value == 2)
		#expect(revertCount.value == 0)
	}

	@Test
	func completionEventFailureAfterRetryRevertsSaveAndShowsError() async throws {
		let now = TestFixtures.fixedNow

		let pet = TestFixtures.pet()
		let habit = TestFixtures.habit(
			id: UUID(uuidString: "00000000-0000-0000-0000-000000000902")!,
			title: "Stretch",
			effort: 1,
			isCompletedToday: false
		)

		let savedHabits = LockIsolated([Habit]())
		let appendCount = LockIsolated(0)

		let store = await TestStore(
			initialState: makeLoadedState(pet: pet, habits: [habit], tasks: [])
		) {
			HomeFeature()
		} withDependencies: {
			$0.dateProvider.now = { now }
			$0.uuidProvider.make = { UUID(uuidString: "00000000-0000-0000-0000-00000000E004")! }

			$0.habitRepository.saveHabit = { updated in
				savedHabits.withValue { $0.append(updated) }
			}

			$0.completionEventRepository.append = { _ in
				appendCount.withValue { $0 += 1 }
				throw AppError.repository(message: "Permanent append failure")
			}
		}

		let expectedUpdatedHabit = completedHabit(from: habit, now: now)
		let expectedError = HomeFeatureError.completionFailed(
			.repository(message: "Failed to append completion event after retry. Completion was reverted.")
		)

		await store.send(.habitCompleteTapped(habit.id)) {
			$0.errorMessage = nil
			$0.completingHabitIDs = [habit.id]
		}

		await store.receive(
			.completionResponse(.habit(habit.id), .failure(expectedError))
		) {
			$0.errorMessage = expectedError.errorDescription
			$0.completingHabitIDs = []
		}

		#expect(savedHabits.value.count == 2)
		#expect(savedHabits.value.first == expectedUpdatedHabit)
		#expect(savedHabits.value.last == habit)
		#expect(appendCount.value == 2)
	}

	private func makeLoadedState(
		pet: Pet,
		habits: [Habit],
		tasks: [TaskItem]
	) -> HomeFeature.State {
		let overload = BurnoutEngine.evaluate(habits: habits, tasks: tasks)
		let derivedPet = PetEngine.updatePet(
			current: pet,
			completedHabits: habits.filter(\.isCompletedToday).count,
			completedTasks: tasks.filter(\.isCompleted).count,
			overload: overload
		)

		return HomeFeature.State(
			pet: derivedPet,
			sourcePet: pet,
			habits: IdentifiedArray(uniqueElements: habits),
			tasks: IdentifiedArray(uniqueElements: tasks),
			careScore: CareScoreEngine.calculate(
				completedHabits: habits.filter(\.isCompletedToday).count,
				totalHabits: habits.count,
				completedTasks: tasks.filter(\.isCompleted).count,
				totalTasks: tasks.count
			),
			overloadLevel: overload,
			message: PetEngine.message(
				for: derivedPet,
				totalCompleted: habits.filter(\.isCompletedToday).count + tasks.filter(\.isCompleted).count,
				overload: overload
			),
			isLoading: false,
			errorMessage: nil,
			completingHabitIDs: [],
			completingTaskIDs: [],
			bootstrap: nil
		)
	}

	private func completedHabit(from habit: Habit, now: Date) -> Habit {
		var updatedHabit = habit
		updatedHabit.isCompletedToday = true
		updatedHabit.syncMetadata.updatedAt = now
		updatedHabit.syncMetadata.syncStatus = .pendingUpdate
		return updatedHabit
	}

	private func completedTask(from task: TaskItem, now: Date) -> TaskItem {
		var updatedTask = task
		updatedTask.isCompleted = true
		updatedTask.syncMetadata.updatedAt = now
		updatedTask.syncMetadata.syncStatus = .pendingUpdate
		return updatedTask
	}
}
