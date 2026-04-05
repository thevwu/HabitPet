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
		var pet: Pet
		var habits: IdentifiedArrayOf<Habit>
		var tasks: IdentifiedArrayOf<TaskItem>
		var careScore: Int
		var overloadLevel: BurnoutLevel
		var message: String

		static let demo = State(
			pet: DemoFixtures.pet,
			habits: DemoFixtures.habits,
			tasks: DemoFixtures.tasks,
			careScore: 72,
			overloadLevel: .light,
			message: "Your pet is waiting to see how today goes."
		)
	}

	enum Action: Equatable {
		case onAppear
		case habitCompleteTapped(UUID)
		case taskCompleteTapped(UUID)
	}

	var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .onAppear:
				recalculate(state: &state)
				return .none

			case let .habitCompleteTapped(id):
				guard var habit = state.habits[id: id], !habit.isCompletedToday else {
					return .none
				}

				habit.isCompletedToday = true
				state.habits[id: id] = habit
				recalculate(state: &state)
				return .none

			case let .taskCompleteTapped(id):
				guard var task = state.tasks[id: id], !task.isCompleted else {
					return .none
				}

				task.isCompleted = true
				state.tasks[id: id] = task
				recalculate(state: &state)
				return .none
			}
		}
	}

	private func recalculate(state: inout State) {
		let completedHabits = state.habits.filter(\.isCompletedToday).count
		let completedTasks = state.tasks.filter(\.isCompleted).count
		let totalCompleted = completedHabits + completedTasks

		state.careScore = CareScoreEngine.calculate(
			completedHabits: completedHabits,
			totalHabits: state.habits.count,
			completedTasks: completedTasks,
			totalTasks: state.tasks.count
		)

		state.overloadLevel = BurnoutEngine.evaluate(
			habits: Array(state.habits),
			tasks: Array(state.tasks)
		)

		state.pet = PetEngine.updatePet(
			current: state.pet,
			completedHabits: completedHabits,
			completedTasks: completedTasks,
			overload: state.overloadLevel
		)

		state.message = PetEngine.message(
			for: state.pet,
			totalCompleted: totalCompleted,
			overload: state.overloadLevel
		)
	}
}
