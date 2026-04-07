////
//	HabitPet
//	PetMapper.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

enum PetMapper {
    static func toDomain(_ entity: PetEntity) -> Pet? {
        guard
            let id = entity.id,
            let name = entity.name,
            let typeRaw = entity.typeRaw,
            let moodRaw = entity.moodRaw,
            let type = PetType(rawValue: typeRaw),
            let mood = PetMood(rawValue: moodRaw),
            let createdAt = entity.createdAt,
            let updatedAt = entity.updatedAt,
            let syncStatusRaw = entity.syncStatusRaw,
            let syncStatus = SyncStatus(rawValue: syncStatusRaw)
        else {
            return nil
        }

        return Pet(
            id: id,
            name: name,
            type: type,
            mood: mood,
            energy: Int(entity.energy),
            affection: Int(entity.affection),
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

    static func upsert(_ pet: Pet, into entity: PetEntity) {
        entity.id = pet.id
        entity.name = pet.name
        entity.typeRaw = pet.type.rawValue
        entity.moodRaw = pet.mood.rawValue
        entity.energy = Int16(pet.energy)
        entity.affection = Int16(pet.affection)
        entity.createdAt = pet.syncMetadata.createdAt
        entity.updatedAt = pet.syncMetadata.updatedAt
        entity.deletedAt = pet.syncMetadata.deletedAt
        entity.syncStatusRaw = pet.syncMetadata.syncStatus.rawValue
        entity.serverUpdatedAt = pet.syncMetadata.serverUpdatedAt
        entity.originDeviceID = pet.syncMetadata.originDeviceID
    }
}
