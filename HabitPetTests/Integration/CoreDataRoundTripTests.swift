////
//	HabitPet
//	CoreDataRoundTripTests.swift
//
//	Created by: thevwu on 2026
//


import Testing
@testable import HabitPet

struct CoreDataRoundTripTests {
    @Test
    func petRoundTripThroughCoreData() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        let pet = TestFixtures.pet(
            name: "Miso",
            type: .cat,
            mood: .energetic,
            energy: 77,
            affection: 88
        )

        try await repos.pet.savePet(pet)
        let fetched = try await repos.pet.fetchPet()

        #expect(fetched != nil)
        #expect(fetched?.id == pet.id)
        #expect(fetched?.name == "Miso")
        #expect(fetched?.type == .cat)
        #expect(fetched?.mood == .energetic)
        #expect(fetched?.energy == 77)
        #expect(fetched?.affection == 88)
    }

    @Test
    func habitsRoundTripThroughCoreData() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        let habits = TestFixtures.habits()

        for habit in habits {
            try await repos.habit.saveHabit(habit)
        }

        let fetched = try await repos.habit.fetchHabits()

        #expect(fetched.count == habits.count)
        #expect(Set(fetched.map(\.title)) == Set(habits.map(\.title)))
    }

    @Test
    func tasksRoundTripThroughCoreData() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        let tasks = TestFixtures.tasks()

        for task in tasks {
            try await repos.task.saveTask(task)
        }

        let fetched = try await repos.task.fetchTasks()

        #expect(fetched.count == tasks.count)
        #expect(Set(fetched.map(\.title)) == Set(tasks.map(\.title)))
    }

    @Test
    func completionEventRoundTripThroughCoreData() async throws {
        let persistence = InMemoryTestStore.makePersistenceController()
        let repos = InMemoryTestStore.makeRepositories(persistence: persistence)

        let habit = TestFixtures.habit()
        let event = TestFixtures.completionEvent(
            itemID: habit.id,
            itemType: .habit,
            completedAt: TestFixtures.fixedNow,
            effort: habit.effort
        )

        try await repos.completion.append(event)
        let fetched = try await repos.completion.fetchEvents(forDayContaining: TestFixtures.fixedNow)

        #expect(fetched.count == 1)
        #expect(fetched.first?.id == event.id)
        #expect(fetched.first?.itemID == habit.id)
        #expect(fetched.first?.itemType == .habit)
        #expect(fetched.first?.effort == habit.effort)
    }
}