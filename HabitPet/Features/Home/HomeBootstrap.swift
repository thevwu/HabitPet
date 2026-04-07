////
//	HabitPet
//	HomeBootstrap.swift
//
//	Created by: thevwu on 2026
//


import Foundation

struct HomeBootstrap: Equatable, Sendable {
    var petName: String
    var petType: PetType
    var starterHabits: [Habit]

    static func `default`(now: Date) -> Self {
        Self(
            petName: "Mochi",
            petType: .dog,
            starterHabits: [
                Habit(
                    id: UUID(),
                    title: "Drink water",
                    effort: 1,
                    isCompletedToday: false,
                    syncMetadata: .fresh(now: now)
                ),
                Habit(
                    id: UUID(),
                    title: "Go for a run",
                    effort: 3,
                    isCompletedToday: false,
                    syncMetadata: .fresh(now: now)
                ),
                Habit(
                    id: UUID(),
                    title: "Read 20 minutes",
                    effort: 2,
                    isCompletedToday: false,
                    syncMetadata: .fresh(now: now)
                )
            ]
        )
    }
}