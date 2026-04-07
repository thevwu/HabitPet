////
//	HabitPet
//	HabitMapper.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

enum HabitMapper {
    static func toDomain(_ entity: HabitEntity) -> Habit? {
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

        return Habit(
            id: id,
            title: title,
            effort: Int(entity.effort),
            isCompletedToday: entity.isCompletedToday,
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

    static func upsert(_ habit: Habit, into entity: HabitEntity) {
        entity.id = habit.id
        entity.title = habit.title
        entity.effort = Int16(habit.effort)
        entity.isCompletedToday = habit.isCompletedToday
        entity.createdAt = habit.syncMetadata.createdAt
        entity.updatedAt = habit.syncMetadata.updatedAt
        entity.deletedAt = habit.syncMetadata.deletedAt
        entity.syncStatusRaw = habit.syncMetadata.syncStatus.rawValue
        entity.serverUpdatedAt = habit.syncMetadata.serverUpdatedAt
        entity.originDeviceID = habit.syncMetadata.originDeviceID
    }
}
