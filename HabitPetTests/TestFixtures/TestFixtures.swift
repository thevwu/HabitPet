////
//	HabitPet
//	TestFixtures.swift
//
//	Created by: thevwu on 2026
//

import Foundation
@testable import HabitPet

enum TestFixtures {
	static let fixedNow = Date(timeIntervalSince1970: 1_700_000_000)

	static func syncMetadata(
		createdAt: Date = fixedNow,
		updatedAt: Date? = nil,
		deletedAt: Date? = nil,
		syncStatus: SyncStatus = .synced,
		serverUpdatedAt: Date? = nil,
		originDeviceID: String? = "test-device"
	) -> SyncMetadata {
		SyncMetadata(
			createdAt: createdAt,
			updatedAt: updatedAt ?? createdAt,
			deletedAt: deletedAt,
			syncStatus: syncStatus,
			serverUpdatedAt: serverUpdatedAt,
			originDeviceID: originDeviceID
		)
	}

	static func pet(
		id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
		name: String = "Mochi",
		type: PetType = .dog,
		mood: PetMood = .neutral,
		energy: Int = 65,
		affection: Int = 60,
		syncMetadata: SyncMetadata? = nil
	) -> Pet {
		Pet(
			id: id,
			name: name,
			type: type,
			mood: mood,
			energy: energy,
			affection: affection,
			syncMetadata: syncMetadata ?? self.syncMetadata()
		)
	}

	static func habit(
		id: UUID = UUID(),
		title: String = "Drink water",
		effort: Int = 1,
		isCompletedToday: Bool = false,
		syncMetadata: SyncMetadata? = nil
	) -> Habit {
		Habit(
			id: id,
			title: title,
			effort: effort,
			isCompletedToday: isCompletedToday,
			syncMetadata: syncMetadata ?? self.syncMetadata()
		)
	}

	static func task(
		id: UUID = UUID(),
		title: String = "Reply to recruiter",
		effort: Int = 2,
		isCompleted: Bool = false,
		syncMetadata: SyncMetadata? = nil
	) -> TaskItem {
		TaskItem(
			id: id,
			title: title,
			effort: effort,
			isCompleted: isCompleted,
			syncMetadata: syncMetadata ?? self.syncMetadata()
		)
	}

	static func completionEvent(
		id: UUID = UUID(),
		itemID: UUID,
		itemType: CompletionItemType,
		completedAt: Date = fixedNow,
		effort: Int = 1,
		syncMetadata: SyncMetadata? = nil
	) -> CompletionEvent {
		CompletionEvent(
			id: id,
			itemID: itemID,
			itemType: itemType,
			completedAt: completedAt,
			effort: effort,
			syncMetadata: syncMetadata ?? self.syncMetadata(createdAt: completedAt)
		)
	}

	static func habits() -> [Habit] {
		[
			habit(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
				title: "Drink water",
				effort: 1,
				isCompletedToday: false
			),
			habit(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
				title: "Go for a run",
				effort: 3,
				isCompletedToday: false
			),
			habit(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
				title: "Read 20 minutes",
				effort: 2,
				isCompletedToday: false
			)
		]
	}

	static func tasks() -> [TaskItem] {
		[
			task(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
				title: "Reply to recruiter",
				effort: 2,
				isCompleted: false
			),
			task(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!,
				title: "Review resume bullets",
				effort: 2,
				isCompleted: false
			)
		]
	}
}
