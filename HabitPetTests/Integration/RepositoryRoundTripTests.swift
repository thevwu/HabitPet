////
//	HabitPet
//	RepositoryRoundTripTests.swift
//
//	Created by: thevwu on 2026
//


import Testing
import Foundation
@testable import HabitPet

struct RepositoryRoundTripTests {
    @Test
    func seedIfNeededCreatesInitialDataOnlyOnce() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

		try await repos.pet.seedIfNeeded(now: TestFixtures.fixedNow, bootstrap: nil)
		try await repos.pet.seedIfNeeded(now: TestFixtures.fixedNow, bootstrap: nil)

        let pet = try await repos.pet.fetchPet()

        #expect(pet != nil)
        #expect(pet?.name == "Mochi")
    }

    @Test
    func saveHabitThenFetchReturnsUpdatedHabit() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        var habit = TestFixtures.habit(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000009999")!,
            title: "Deep work",
            effort: 3,
            isCompletedToday: false
        )

        try await repos.habit.saveHabit(habit)

        habit.isCompletedToday = true
        habit.syncMetadata.updatedAt = TestFixtures.fixedNow.addingTimeInterval(60)
        habit.syncMetadata.syncStatus = .pendingUpdate

        try await repos.habit.saveHabit(habit)

        let fetched = try await repos.habit.fetchHabits()
        let updated = fetched.first(where: { $0.id == habit.id })

        #expect(updated != nil)
        #expect(updated?.isCompletedToday == true)
        #expect(updated?.effort == 3)
        #expect(updated?.syncMetadata.syncStatus == .pendingUpdate)
    }

    @Test
    func saveTaskThenFetchReturnsUpdatedTask() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        var task = TestFixtures.task(
            title: "Prepare portfolio",
            effort: 2,
            isCompleted: false
        )

        try await repos.task.saveTask(task)

        task.isCompleted = true
        task.syncMetadata.updatedAt = TestFixtures.fixedNow.addingTimeInterval(120)
        task.syncMetadata.syncStatus = .pendingUpdate

        try await repos.task.saveTask(task)

        let fetched = try await repos.task.fetchTasks()
        let updated = fetched.first(where: { $0.id == task.id })

        #expect(updated != nil)
        #expect(updated?.isCompleted == true)
        #expect(updated?.syncMetadata.syncStatus == .pendingUpdate)
    }

    @Test
    func appendingTwoSameDayEventsReturnsBoth() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        let habit = TestFixtures.habit(title: "Hydrate", effort: 1)
        let task = TestFixtures.task(title: "Inbox zero", effort: 2)

        let event1 = TestFixtures.completionEvent(
            itemID: habit.id,
            itemType: .habit,
            completedAt: TestFixtures.fixedNow,
            effort: 1
        )

        let event2 = TestFixtures.completionEvent(
            itemID: task.id,
            itemType: .task,
            completedAt: TestFixtures.fixedNow.addingTimeInterval(300),
            effort: 2
        )

        try await repos.completion.append(event1)
        try await repos.completion.append(event2)

        let fetched = try await repos.completion.fetchEvents(forDayContaining: TestFixtures.fixedNow)

        #expect(fetched.count == 2)
        #expect(Set(fetched.map(\.itemType)) == Set([.habit, .task]))
    }
}
