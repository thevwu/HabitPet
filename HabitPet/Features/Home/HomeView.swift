////
//	HabitPet
//	HomeView.swift
//
//	Created by: thevwu on 2026
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
	let store: StoreOf<HomeFeature>
		
	var body: some View {
		if let errorMessage = store.errorMessage {
			Text(errorMessage)
				.font(.footnote)
				.foregroundStyle(.red)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
		
		if store.pet == nil && !store.isLoading {
			Button("Retry") {
				store.send(.refresh)
			}
			.buttonStyle(.borderedProminent)
		}
		
		VStack(spacing: 16) {
			petCard
			todaySection
			Spacer()
		}
		.padding()
		.navigationTitle("HabitPet")
		.onAppear {
			store.send(.onAppear)
		}
	}

	private var petCard: some View {
		VStack(spacing: 12) {
			Text(store.pet?.mood.emoji ?? "🐾")
				.font(.system(size: 72))

			Text(store.pet?.name ?? "Loading..")
				.font(.title2.bold())

			Text(store.pet?.mood.displayName ?? "...")
				.font(.headline)
				.foregroundStyle(.secondary)

			Text(store.message)
				.font(.subheadline)
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)

			HStack(spacing: 12) {
				statPill(title: "Care", value: "\(store.careScore)")
				statPill(title: "Energy", value: "\(store.pet?.energy ?? 0)")
				statPill(title: "Affection", value: "\(store.pet?.affection ?? 0)")
				statPill(title: "Load", value: store.overloadLevel.displayName)
			}
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background(.thinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 20))
	}

	private var todaySection: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				habitsList
				tasksList
			}
		}
	}

	private var habitsList: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Today’s Habits")
				.font(.title3.bold())

			ForEach(store.habits) { habit in
				let isCompleting = store.completingHabitIDs.contains(habit.id)

				itemRow(
					title: habit.title,
					subtitle: "Effort \(habit.effort)",
					isComplete: habit.isCompletedToday,
					isWorking: isCompleting,
					buttonTitle: habit.isCompletedToday ? "Done" : (isCompleting ? "Saving..." : "Complete")
				) {
					store.send(.habitCompleteTapped(habit.id))
				}
			}
		}
	}

	private var tasksList: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Tasks")
				.font(.title3.bold())

			ForEach(store.tasks) { task in
				let isCompleting = store.completingTaskIDs.contains(task.id)

				itemRow(
					title: task.title,
					subtitle: "Effort \(task.effort)",
					isComplete: task.isCompleted,
					isWorking: isCompleting,
					buttonTitle: task.isCompleted ? "Done" : (isCompleting ? "Saving..." : "Complete")
				) {
					store.send(.taskCompleteTapped(task.id))
				}
			}
		}
	}

	private func itemRow(
		title: String,
		subtitle: String,
		isComplete: Bool,
		isWorking: Bool,
		buttonTitle: String,
		action: @escaping () -> Void
	) -> some View {
		HStack(spacing: 12) {
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.headline)

				Text(subtitle)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			Spacer()

			Button(buttonTitle, action: action)
				.buttonStyle(.borderedProminent)
				.disabled(isComplete || isWorking)
		}
		.padding()
		.background(Color(uiColor: .secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}

	private func statPill(title: String, value: String) -> some View {
		VStack(spacing: 4) {
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(value)
				.font(.headline)
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 12)
		.background(Color(uiColor: .secondarySystemBackground))
		.clipShape(Capsule())
	}
}
