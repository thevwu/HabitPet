////
//	HabitPet
//	AppFeature.swift
//
//	Created by: thevwu on 2026
//

import SwiftUI
import ComposableArchitecture

@main
struct HabitPetApp: App {
	var body: some Scene {
		WindowGroup {
			AppView(
				store: Store(
					initialState: AppFeature.State(),
					reducer: { AppFeature() }
				)
			)
		}
	}
}
