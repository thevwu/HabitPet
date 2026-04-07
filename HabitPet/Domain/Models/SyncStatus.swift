////
//	HabitPet
//	SyncStatus.swift
//
//	Created by: thevwu on 2026
//

import Foundation

enum SyncStatus: String, Equatable, Codable, Sendable {
	case pendingCreate
	case pendingUpdate
	case pendingDelete
	case synced
}
