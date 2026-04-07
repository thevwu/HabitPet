////
//	HabitPet
//	HomeSeedFactory.swift
//
//	Created by: thevwu on 2026
//


import Foundation

enum HomeSeedFactory {
    static func makePet(from bootstrap: HomeBootstrap, now: Date) -> Pet {
        Pet(
            id: UUID(),
            name: bootstrap.petName,
            type: bootstrap.petType,
            mood: .neutral,
            energy: 65,
            affection: 60,
            syncMetadata: .fresh(now: now)
        )
    }

    static func makeHabits(from bootstrap: HomeBootstrap) -> [Habit] {
        bootstrap.starterHabits
    }

    static func makeTasks(now: Date) -> [TaskItem] {
        [
            TaskItem(
                id: UUID(),
                title: "Check in with your pet",
                effort: 1,
                isCompleted: false,
                syncMetadata: .fresh(now: now)
            )
        ]
    }
}