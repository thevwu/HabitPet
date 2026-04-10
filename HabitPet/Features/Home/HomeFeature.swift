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
		var sourcePet: Pet?
		var habits: IdentifiedArrayOf<Habit> = []
		var tasks: IdentifiedArrayOf<TaskItem> = []
		var careScore: Int = 0
		var overloadLevel: BurnoutLevel = .none
		var message: String = "Loading..."
		var isLoading = false
		var errorMessage: String?
		var completingHabitIDs: Set<UUID> = []
		var completingTaskIDs: Set<UUID> = []
		var bootstrap: HomeBootstrap?

		static let `default` = Self(
			pet: nil,
			sourcePet: nil,
			habits: [],
			tasks: [],
			careScore: 0,
			overloadLevel: .none,
			message: "Loading...",
			isLoading: false,
			errorMessage: nil,
			completingHabitIDs: [],
			completingTaskIDs: [],
			bootstrap: nil
		)
	}

	enum Action: Equatable {
		case onAppear
		case refresh
		case loadResponse(Result<LoadPayload, HomeFeatureError>)
		case habitCompleteTapped(UUID)
		case taskCompleteTapped(UUID)
		case completionResponse(CompletionRequest, Result<CompletionOutcome, HomeFeatureError>)
	}
	
	struct LoadPayload: Equatable {
		var pet: Pet
		var habits: [Habit]
		var tasks: [TaskItem]
		var events: [CompletionEvent]
	}

	enum CompletionRequest: Equatable, Hashable, Sendable {
		case habit(UUID)
		case task(UUID)
	}

	struct CompletionOutcome: Equatable, Sendable {
		enum Target: Equatable, Sendable {
			case habit(Habit)
			case task(TaskItem)
		}

		var target: Target
		var event: CompletionEvent
	}

	enum CancelID: Hashable {
		case load
		case completion(CompletionRequest)
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
				apply(sourcePet: payload.pet, habits: payload.habits, tasks: payload.tasks, to: &state)
				return .none
				
			case let .loadResponse(.failure(error)):
				state.isLoading = false
				state.errorMessage = error.errorDescription
				state.message = "Could not load your pet right now."
				return .none

			case let .habitCompleteTapped(id):
				guard
					let habit = state.habits[id: id],
					!habit.isCompletedToday,
					!state.completingHabitIDs.contains(id)
				else {
					return .none
				}

				state.completingHabitIDs.insert(id)
				state.errorMessage = nil

				return .run { send in
					let request = CompletionRequest.habit(id)

					do {
						let now = dateProvider.now()
						let updatedHabit = completedHabit(from: habit, now: now)
						let event = CompletionEvent(
							id: uuidProvider.make(),
							itemID: updatedHabit.id,
							itemType: .habit,
							completedAt: now,
							effort: updatedHabit.effort,
							syncMetadata: .fresh(now: now)
						)

						try await habitRepository.saveHabit(updatedHabit)
						try await appendEventWithRecovery(
							event,
							revert: { try await habitRepository.saveHabit(habit) }
						)

						await send(
							.completionResponse(
								request,
								.success(
									CompletionOutcome(
										target: .habit(updatedHabit),
										event: event
									)
								)
							)
						)
					} catch {
						let featureError = HomeFeatureError.completionFailed(.from(error))
						await send(.completionResponse(request, .failure(featureError)))
					}
				}
				.cancellable(id: CancelID.completion(.habit(id)), cancelInFlight: true)

			case let .taskCompleteTapped(id):
				guard
					let task = state.tasks[id: id],
					!task.isCompleted,
					!state.completingTaskIDs.contains(id)
				else {
					return .none
				}

				state.completingTaskIDs.insert(id)
				state.errorMessage = nil

				return .run { send in
					let request = CompletionRequest.task(id)

					do {
						let now = dateProvider.now()
						let updatedTask = completedTask(from: task, now: now)
						let event = CompletionEvent(
							id: uuidProvider.make(),
							itemID: updatedTask.id,
							itemType: .task,
							completedAt: now,
							effort: updatedTask.effort,
							syncMetadata: .fresh(now: now)
						)

						try await taskRepository.saveTask(updatedTask)
						try await appendEventWithRecovery(
							event,
							revert: { try await taskRepository.saveTask(task) }
						)

						await send(
							.completionResponse(
								request,
								.success(
									CompletionOutcome(
										target: .task(updatedTask),
										event: event
									)
								)
							)
						)
					} catch {
						let featureError = HomeFeatureError.completionFailed(.from(error))
						await send(.completionResponse(request, .failure(featureError)))
					}
				}
				.cancellable(id: CancelID.completion(.task(id)), cancelInFlight: true)
				
			case let .completionResponse(request, .success(outcome)):
				clearInFlight(request, from: &state)
				state.errorMessage = nil

				var habits = Array(state.habits)
				var tasks = Array(state.tasks)

				switch outcome.target {
				case let .habit(updatedHabit):
					upsert(updatedHabit, in: &habits)

				case let .task(updatedTask):
					upsert(updatedTask, in: &tasks)
				}

				let sourcePet = state.sourcePet ?? state.pet
				guard let sourcePet else {
					state.errorMessage = HomeFeatureError.completionFailed(
						.repository(message: "Home state could not be reconciled because the base pet is missing.")
					).errorDescription
					return .none
				}

				apply(sourcePet: sourcePet, habits: habits, tasks: tasks, to: &state)
				return .none

			case let .completionResponse(request, .failure(error)):
				clearInFlight(request, from: &state)
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

	private func apply(
		sourcePet: Pet,
		habits: [Habit],
		tasks: [TaskItem],
		to state: inout State
	) {
		let completedHabits = habits.filter(\.isCompletedToday).count
		let completedTasks = tasks.filter(\.isCompleted).count
		let overload = BurnoutEngine.evaluate(habits: habits, tasks: tasks)

		let derivedPet = PetEngine.updatePet(
			current: sourcePet,
			completedHabits: completedHabits,
			completedTasks: completedTasks,
			overload: overload
		)

		state.sourcePet = sourcePet
		state.pet = derivedPet
		state.habits = IdentifiedArray(uniqueElements: habits)
		state.tasks = IdentifiedArray(uniqueElements: tasks)
		state.overloadLevel = overload
		state.careScore = CareScoreEngine.calculate(
			completedHabits: completedHabits,
			totalHabits: habits.count,
			completedTasks: completedTasks,
			totalTasks: tasks.count
		)
		state.message = PetEngine.message(
			for: derivedPet,
			totalCompleted: completedHabits + completedTasks,
			overload: overload
		)
	}
	
	private func appendEventWithRecovery(
		_ event: CompletionEvent,
		revert: @escaping @Sendable () async throws -> Void
	) async throws {
		do {
			try await completionEventRepository.append(event)
		} catch {
			do {
				try await completionEventRepository.append(event)
			} catch {
				do {
					try await revert()
				} catch {
					let revertError = AppError.from(error)
					throw AppError.repository(
						message: "Failed to append completion event after retry and failed to revert completion: \(revertError.errorDescription ?? "unknown error")"
					)
				}

				throw AppError.repository(
					message: "Failed to append completion event after retry. Completion was reverted."
				)
			}
		}
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
	
	private func clearInFlight(_ request: CompletionRequest, from state: inout State) {
		switch request {
		case let .habit(id):
			state.completingHabitIDs.remove(id)

		case let .task(id):
			state.completingTaskIDs.remove(id)
		}
	}

	private func upsert(_ habit: Habit, in habits: inout [Habit]) {
		guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
			habits.append(habit)
			return
		}

		habits[index] = habit
	}

	private func upsert(_ task: TaskItem, in tasks: inout [TaskItem]) {
		guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
			tasks.append(task)
			return
		}

		tasks[index] = task
	}
}
