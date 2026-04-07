////
//	HabitPet
//	SyncMetadata.swift
//
//	Created by: thevwu on 2026
//


import Foundation

struct SyncMetadata: Equatable, Codable, Sendable {
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var syncStatus: SyncStatus
    var serverUpdatedAt: Date?
    var originDeviceID: String?

    static func fresh(now: Date) -> Self {
        Self(
            createdAt: now,
            updatedAt: now,
            deletedAt: nil,
            syncStatus: .pendingCreate,
            serverUpdatedAt: nil,
            originDeviceID: nil
        )
    }
}