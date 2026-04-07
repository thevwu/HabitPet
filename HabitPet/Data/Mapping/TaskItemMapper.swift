////
//	HabitPet
//	TaskItemMapper.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

enum TaskItemMapper {
    static func toDomain(_ entity: TaskItemEntity) -> TaskItem? {
        guard
            let id = entity.id,
            let title = entity.title,
            let createdAt = entity.createdAt,
            let updatedAt = entity.updatedAt,
            let syncStatusRaw = entity.syncStatusRaw,
            let syncStatus = SyncStatus(rawValue: syncStatusRaw)
        else {
            return nil
        }

        return TaskItem(
            id: id,
            title: title,
            effort: Int(entity.effort),
            isCompleted: entity.isCompleted,
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

    static func upsert(_ task: TaskItem, into entity: TaskItemEntity) {
        entity.id = task.id
        entity.title = task.title
        entity.effort = Int16(task.effort)
        entity.isCompleted = task.isCompleted
        entity.createdAt = task.syncMetadata.createdAt
        entity.updatedAt = task.syncMetadata.updatedAt
        entity.deletedAt = task.syncMetadata.deletedAt
        entity.syncStatusRaw = task.syncMetadata.syncStatus.rawValue
        entity.serverUpdatedAt = task.syncMetadata.serverUpdatedAt
        entity.originDeviceID = task.syncMetadata.originDeviceID
    }
}
