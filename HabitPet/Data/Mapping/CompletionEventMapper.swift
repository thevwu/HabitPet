////
//	HabitPet
//	CompletionEventMapper.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

enum CompletionEventMapper {
    static func toDomain(_ entity: CompletionEventEntity) -> CompletionEvent? {
        guard
            let id = entity.id,
            let itemID = entity.itemID,
            let itemTypeRaw = entity.itemTypeRaw,
            let itemType = CompletionItemType(rawValue: itemTypeRaw),
            let completedAt = entity.completedAt,
            let createdAt = entity.createdAt,
            let updatedAt = entity.updatedAt,
            let syncStatusRaw = entity.syncStatusRaw,
            let syncStatus = SyncStatus(rawValue: syncStatusRaw)
        else {
            return nil
        }

        return CompletionEvent(
            id: id,
            itemID: itemID,
            itemType: itemType,
            completedAt: completedAt,
            effort: Int(entity.effort),
            syncMetadata: SyncMetadata(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: entity.deletedAt,
                syncStatus: syncStatus,
                serverUpdatedAt: entity.serverUpdatedAt,
                originDeviceID: entity.originDeviceID
            )
        )
    }

    static func upsert(_ event: CompletionEvent, into entity: CompletionEventEntity) {
        entity.id = event.id
        entity.itemID = event.itemID
        entity.itemTypeRaw = event.itemType.rawValue
        entity.completedAt = event.completedAt
        entity.effort = Int16(event.effort)
        entity.createdAt = event.syncMetadata.createdAt
        entity.updatedAt = event.syncMetadata.updatedAt
        entity.deletedAt = event.syncMetadata.deletedAt
        entity.syncStatusRaw = event.syncMetadata.syncStatus.rawValue
        entity.serverUpdatedAt = event.syncMetadata.serverUpdatedAt
        entity.originDeviceID = event.syncMetadata.originDeviceID
    }
}
