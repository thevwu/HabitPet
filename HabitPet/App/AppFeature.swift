////
//	HabitPet
//	AppFeature.swift
//
//	Created by: thevwu on 2026
//

import ComposableArchitecture

@Reducer
struct AppFeature {
	@ObservableState
	struct State: Equatable {
		var home = HomeFeature.State.mock
	}

	enum Action {
		case home(HomeFeature.Action)
	}

	var body: some Reducer<State, Action> {
		Scope(state: \.home, action: \.home) {
			HomeFeature()
		}

		Reduce { state, action in
			switch action {
			case .home:
				return .none
			}
		}
	}
}
