////
//	HabitPet
//	AppDependencies.swift
//
//	Created by: thevwu on 2026
//

import ComposableArchitecture
import Foundation

struct PetRepositoryClient: Sendable {
	var fetchPet: @Sendable () async throws -> Pet?
	var savePet: @Sendable (Pet) async throws -> Void
	var seedIfNeeded: @Sendable (Date, HomeBootstrap?) async throws -> Void
}

struct HabitRepositoryClient: Sendable {
	var fetchHabits: @Sendable () async throws -> [Habit]
	var saveHabit: @Sendable (Habit) async throws -> Void
	var seedIfNeeded: @Sendable (Date, HomeBootstrap?) async throws -> Void
}

struct TaskRepositoryClient: Sendable {
	var fetchTasks: @Sendable () async throws -> [TaskItem]
	var saveTask: @Sendable (TaskItem) async throws -> Void
	var seedIfNeeded: @Sendable (Date, HomeBootstrap?) async throws -> Void
}

struct CompletionEventRepositoryClient: Sendable {
	var fetchEventsForDay: @Sendable (Date) async throws -> [CompletionEvent]
	var append: @Sendable (CompletionEvent) async throws -> Void
}

struct DateProvider: Sendable {
	var now: @Sendable () -> Date
}

struct UUIDProvider: Sendable {
	var make: @Sendable () -> UUID
}

private enum PetRepositoryKey: DependencyKey {
	static let liveValue = PetRepositoryClient.unimplemented
	static let testValue = PetRepositoryClient.unimplemented
}

private enum HabitRepositoryKey: DependencyKey {
	static let liveValue = HabitRepositoryClient.unimplemented
	static let testValue = HabitRepositoryClient.unimplemented
}

private enum TaskRepositoryKey: DependencyKey {
	static let liveValue = TaskRepositoryClient.unimplemented
	static let testValue = TaskRepositoryClient.unimplemented
}

private enum CompletionEventRepositoryKey: DependencyKey {
	static let liveValue = CompletionEventRepositoryClient.unimplemented
	static let testValue = CompletionEventRepositoryClient.unimplemented
}

private enum DateProviderKey: DependencyKey {
	static let liveValue = DateProvider(now: { Date() })
	static let testValue = DateProvider(now: { Date(timeIntervalSince1970: 0) })
}

private enum UUIDProviderKey: DependencyKey {
	static let liveValue = UUIDProvider(make: { UUID() })
	static let testValue = UUIDProvider(make: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! })
}

extension DependencyValues {
	var petRepository: PetRepositoryClient {
		get { self[PetRepositoryKey.self] }
		set { self[PetRepositoryKey.self] = newValue }
	}

	var habitRepository: HabitRepositoryClient {
		get { self[HabitRepositoryKey.self] }
		set { self[HabitRepositoryKey.self] = newValue }
	}

	var taskRepository: TaskRepositoryClient {
		get { self[TaskRepositoryKey.self] }
		set { self[TaskRepositoryKey.self] = newValue }
	}

	var completionEventRepository: CompletionEventRepositoryClient {
		get { self[CompletionEventRepositoryKey.self] }
		set { self[CompletionEventRepositoryKey.self] = newValue }
	}

	var dateProvider: DateProvider {
		get { self[DateProviderKey.self] }
		set { self[DateProviderKey.self] = newValue }
	}

	var uuidProvider: UUIDProvider {
		get { self[UUIDProviderKey.self] }
		set { self[UUIDProviderKey.self] = newValue }
	}
}

extension PetRepositoryClient {
	static let unimplemented = Self(
		fetchPet: { throw AppError.repository(message: "petRepository.fetchPet not implemented") },
		savePet: { _ in throw AppError.repository(message: "petRepository.savePet not implemented") },
		seedIfNeeded: { _, _ in throw AppError.repository(message: "petRepository.seedIfNeeded not implemented") }
	)
}

extension HabitRepositoryClient {
	static let unimplemented = Self(
		fetchHabits: { throw AppError.repository(message: "habitRepository.fetchHabits not implemented") },
		saveHabit: { _ in throw AppError.repository(message: "habitRepository.saveHabit not implemented") },
		seedIfNeeded: { _, _ in throw AppError.repository(message: "habitRepository.seedIfNeeded not implemented") }
	)
}

extension TaskRepositoryClient {
	static let unimplemented = Self(
		fetchTasks: { throw AppError.repository(message: "taskRepository.fetchTasks not implemented") },
		saveTask: { _ in throw AppError.repository(message: "taskRepository.saveTask not implemented") },
		seedIfNeeded: { _, _ in throw AppError.repository(message: "taskRepository.seedIfNeeded not implemented") }
	)
}

extension CompletionEventRepositoryClient {
    static let unimplemented = Self(
        fetchEventsForDay: { _ in throw AppError.repository(message: "completionEventRepository.fetchEventsForDay not implemented") },
        append: { _ in throw AppError.repository(message: "completionEventRepository.append not implemented") }
    )
}
