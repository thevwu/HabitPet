////
//	HabitPet
//	DemoFixtures.swift
//
//	Created by: thevwu on 2026
//


import Foundation
import ComposableArchitecture
@testable import HabitPet

enum DemoFixtures {
    static let now = TestFixtures.fixedNow

    static let pet = TestFixtures.pet()

    static let habits = TestFixtures.habits()
    static let tasks = TestFixtures.tasks()

    static var homeLoadedState: HomeFeature.State {
        let habits = self.habits
        let tasks = self.tasks
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
            errorMessage: nil
        )
    }
}
