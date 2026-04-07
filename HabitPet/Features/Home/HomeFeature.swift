////
//	HabitPet
//	HomeFeature.swift
//
//	Created by: thevwu on 2026
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature {
	@ObservableState
	struct State: Equatable {
		var pet: Pet?
		var habits: IdentifiedArrayOf<Habit> = []
		var tasks: IdentifiedArrayOf<TaskItem> = []
		var careScore: Int = 0
		var overloadLevel: BurnoutLevel = .none
		var message: String = "Loading..."
		var isLoading = false
		var errorMessage: String?
		var bootstrap: HomeBootstrap?

		static let `default` = Self(
			pet: nil,
			habits: [],
			tasks: [],
			careScore: 0,
			overloadLevel: .none,
			message: "Loading...",
			isLoading: false,
			errorMessage: nil,
			bootstrap: nil
		)
	}

	enum Action: Equatable {
		case onAppear
		case refresh
		case loadResponse(Result<LoadPayload, HomeFeatureError>)
		case habitCompleteTapped(UUID)
		case taskCompleteTapped(UUID)
		case completionResponse(Result<LoadPayload, HomeFeatureError>)
	}

	struct LoadPayload: Equatable {
		var pet: Pet
		var habits: [Habit]
		var tasks: [TaskItem]
		var events: [CompletionEvent]
	}

	enum CancelID {
		case load
		case complete
	}

	@Dependency(\.petRepository) var petRepository
	@Dependency(\.habitRepository) var habitRepository
	@Dependency(\.taskRepository) var taskRepository
	@Dependency(\.completionEventRepository) var completionEventRepository
	@Dependency(\.dateProvider) var dateProvider
	@Dependency(\.uuidProvider) var uuidProvider

	var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .onAppear, .refresh:
				state.isLoading = true
				state.errorMessage = nil
				let bootstrap = state.bootstrap

				return .run { send in
					do {
						let now = dateProvider.now()

						async let seedPet: Void = petRepository.seedIfNeeded(now, bootstrap)
						async let seedHabits: Void = habitRepository.seedIfNeeded(now, bootstrap)
						async let seedTasks: Void = taskRepository.seedIfNeeded(now, bootstrap)

						_ = try await (seedPet, seedHabits, seedTasks)

						let payload = try await loadPayload(now: now)
						await send(.loadResponse(.success(payload)))
					} catch {
						let featureError = HomeFeatureError.loadFailed(.from(error))
						await send(.loadResponse(.failure(featureError)))
					}
				}
				.cancellable(id: CancelID.load, cancelInFlight: true)

			case let .loadResponse(.success(payload)):
				state.isLoading = false
				state.errorMessage = nil
				apply(payload: payload, to: &state)
				return .none

			case let .loadResponse(.failure(error)):
				state.isLoading = false
				state.errorMessage = error.errorDescription
				state.message = "Could not load your pet right now."
				return .none

			case let .habitCompleteTapped(id):
				guard let habit = state.habits[id: id], !habit.isCompletedToday else {
					return .none
				}

				state.isLoading = true
				state.errorMessage = nil

				return .run { send in
					do {
						let now = dateProvider.now()
						var updatedHabit = habit
						updatedHabit.isCompletedToday = true
						updatedHabit.syncMetadata.updatedAt = now
						updatedHabit.syncMetadata.syncStatus = .pendingUpdate

						try await habitRepository.saveHabit(updatedHabit)

						let event = CompletionEvent(
							id: uuidProvider.make(),
							itemID: updatedHabit.id,
							itemType: .habit,
							completedAt: now,
							effort: updatedHabit.effort,
							syncMetadata: .fresh(now: now)
						)

						try await completionEventRepository.append(event)

						let payload = try await loadPayload(now: now)
						await send(.completionResponse(.success(payload)))
					} catch {
						let featureError = HomeFeatureError.completionFailed(.from(error))
						await send(.completionResponse(.failure(featureError)))
					}
				}
				.cancellable(id: CancelID.complete, cancelInFlight: true)

			case let .taskCompleteTapped(id):
				guard let task = state.tasks[id: id], !task.isCompleted else {
					return .none
				}

				state.isLoading = true
				state.errorMessage = nil

				return .run { send in
					do {
						let now = dateProvider.now()
						var updatedTask = task
						updatedTask.isCompleted = true
						updatedTask.syncMetadata.updatedAt = now
						updatedTask.syncMetadata.syncStatus = .pendingUpdate

						try await taskRepository.saveTask(updatedTask)

						let event = CompletionEvent(
							id: uuidProvider.make(),
							itemID: updatedTask.id,
							itemType: .task,
							completedAt: now,
							effort: updatedTask.effort,
							syncMetadata: .fresh(now: now)
						)

						try await completionEventRepository.append(event)

						let payload = try await loadPayload(now: now)
						await send(.completionResponse(.success(payload)))
					} catch {
						let featureError = HomeFeatureError.completionFailed(.from(error))
						await send(.completionResponse(.failure(featureError)))
					}
				}
				.cancellable(id: CancelID.complete, cancelInFlight: true)

			case let .completionResponse(.success(payload)):
				state.isLoading = false
				state.errorMessage = nil
				apply(payload: payload, to: &state)
				return .none

			case let .completionResponse(.failure(error)):
				state.isLoading = false
				state.errorMessage = error.errorDescription
				return .none
			}
		}
	}

	private func loadPayload(now: Date) async throws -> LoadPayload {
		async let petResult = petRepository.fetchPet()
		async let habitsResult = habitRepository.fetchHabits()
		async let tasksResult = taskRepository.fetchTasks()
		async let eventsResult = completionEventRepository.fetchEventsForDay(now)

		guard let pet = try await petResult else {
			throw AppError.notFound(entity: "Pet")
		}

		return LoadPayload(
			pet: pet,
			habits: try await habitsResult,
			tasks: try await tasksResult,
			events: try await eventsResult
		)
	}

	private func apply(payload: LoadPayload, to state: inout State) {
		let completedHabits = payload.habits.filter(\.isCompletedToday).count
		let completedTasks = payload.tasks.filter(\.isCompleted).count
		let overload = BurnoutEngine.evaluate(habits: payload.habits, tasks: payload.tasks)

		let derivedPet = PetEngine.updatePet(
			current: payload.pet,
			completedHabits: completedHabits,
			completedTasks: completedTasks,
			overload: overload
		)

		state.pet = derivedPet
		state.habits = IdentifiedArray(uniqueElements: payload.habits)
		state.tasks = IdentifiedArray(uniqueElements: payload.tasks)
		state.overloadLevel = overload
		state.careScore = CareScoreEngine.calculate(
			completedHabits: completedHabits,
			totalHabits: payload.habits.count,
			completedTasks: completedTasks,
			totalTasks: payload.tasks.count
		)
		state.message = PetEngine.message(
			for: derivedPet,
			totalCompleted: completedHabits + completedTasks,
			overload: overload
		)
	}
}
