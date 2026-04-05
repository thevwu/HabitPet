////
//	HabitPet
//	AppView.swift
//
//	Created by: thevwu on 2026
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
	let store: StoreOf<AppFeature>

	var body: some View {
		NavigationStack {
			HomeView(
				store: store.scope(state: \.home, action: \.home)
			)
		}
	}
}
