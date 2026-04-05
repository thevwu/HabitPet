////
//	HabitPet
//	HomeFeatureTests.swift
//
//	Created by: thevwu on 2026
//

import XCTest
import ComposableArchitecture
@testable import HabitPet

@MainActor
final class HomeFeatureTests: XCTestCase {
	func testOnAppearRecalculatesInitialState() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.onAppear) {
			$0.careScore = 0
			$0.overloadLevel = .light
			$0.pet.mood = .sleepy
			$0.pet.energy = 61
			$0.pet.affection = 58
			$0.message = "Mochi is waiting for your first completed task."
		}
	}

	func testCompletingHabitMarksHabitDoneAndUpdatesState() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.habitCompleteTapped(TestFixtures.drinkWaterID)) {
			$0.habits[id: TestFixtures.drinkWaterID]?.isCompletedToday = true
			$0.careScore = 23
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}
	}

	func testCompletingTaskMarksTaskDoneAndUpdatesState() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.taskCompleteTapped(TestFixtures.recruiterID)) {
			$0.tasks[id: TestFixtures.recruiterID]?.isCompleted = true
			$0.careScore = 15
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}
	}

	func testCompletingSameHabitTwiceDoesNothingSecondTime() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.habitCompleteTapped(TestFixtures.drinkWaterID)) {
			$0.habits[id: TestFixtures.drinkWaterID]?.isCompletedToday = true
			$0.careScore = 23
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}

		await store.send(.habitCompleteTapped(TestFixtures.drinkWaterID))
	}

	func testCompletingSameTaskTwiceDoesNothingSecondTime() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.taskCompleteTapped(TestFixtures.recruiterID)) {
			$0.tasks[id: TestFixtures.recruiterID]?.isCompleted = true
			$0.careScore = 15
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}

		await store.send(.taskCompleteTapped(TestFixtures.recruiterID))
	}

	func testCompletingMultipleItemsMakesPetEnergetic() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.habitCompleteTapped(TestFixtures.drinkWaterID)) {
			$0.habits[id: TestFixtures.drinkWaterID]?.isCompletedToday = true
			$0.careScore = 23
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}

		await store.send(.taskCompleteTapped(TestFixtures.recruiterID)) {
			$0.tasks[id: TestFixtures.recruiterID]?.isCompleted = true
			$0.careScore = 38
			$0.overloadLevel = .light
			$0.pet.mood = .energetic
			$0.pet.energy = 73
			$0.pet.affection = 66
			$0.message = "Mochi is getting excited. Momentum is building."
		}
	}

	func testCompletingAllItemsMakesPetJoyful() async {
		let store = TestStore(
			initialState: TestFixtures.homeState()
		) {
			HomeFeature()
		}

		await store.send(.habitCompleteTapped(TestFixtures.drinkWaterID)) {
			$0.habits[id: TestFixtures.drinkWaterID]?.isCompletedToday = true
			$0.careScore = 23
			$0.overloadLevel = .light
			$0.pet.mood = .neutral
			$0.message = "Mochi noticed your progress. Keep going."
		}

		await store.send(.habitCompleteTapped(TestFixtures.runID)) {
			$0.habits[id: TestFixtures.runID]?.isCompletedToday = true
			$0.careScore = 47
			$0.overloadLevel = .light
			$0.pet.mood = .energetic
			$0.pet.energy = 73
			$0.pet.affection = 66
			$0.message = "Mochi is getting excited. Momentum is building."
		}

		await store.send(.habitCompleteTapped(TestFixtures.readID)) {
			$0.habits[id: TestFixtures.readID]?.isCompletedToday = true
			$0.careScore = 70
			$0.overloadLevel = .light
			$0.pet.mood = .energetic
			$0.pet.energy = 81
			$0.pet.affection = 72
			$0.message = "Mochi is getting excited. Momentum is building."
		}

		await store.send(.taskCompleteTapped(TestFixtures.recruiterID)) {
			$0.tasks[id: TestFixtures.recruiterID]?.isCompleted = true
			$0.careScore = 85
			$0.overloadLevel = .light
			$0.pet.mood = .joyful
			$0.pet.energy = 96
			$0.pet.affection = 84
			$0.message = "Mochi is thriving today."
		}
	}
}
