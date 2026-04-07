////
//	HabitPet
//	CoreDataCompletionEventRepository.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

struct CoreDataCompletionEventRepository: CompletionEventRepository, Sendable {
    let persistence: PersistenceController
    let calendar: Calendar = .current

    func fetchEvents(forDayContaining date: Date) async throws -> [CompletionEvent] {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return []
        }

        let context = persistence.newBackgroundContext()
        return try await context.performAsync { context in
            let request = CompletionEventEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "completedAt >= %@ AND completedAt < %@",
                start as NSDate,
                end as NSDate
            )
            request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: true)]
            let result = try context.fetch(request)
            return result.compactMap(CompletionEventMapper.toDomain)
        }
    }

    func append(_ event: CompletionEvent) async throws {
        let context = persistence.newBackgroundContext()
        try await context.performAsync { context in
            let entity = CompletionEventEntity(context: context)
            CompletionEventMapper.upsert(event, into: entity)
            try context.saveIfNeeded()
        }
    }
}
