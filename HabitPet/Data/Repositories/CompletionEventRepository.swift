////
//	HabitPet
//	CompletionEventRepository.swift
//
//	Created by: thevwu on 2026
//

import Foundation

protocol CompletionEventRepository: Sendable {
    func fetchEvents(forDayContaining date: Date) async throws -> [CompletionEvent]
    func append(_ event: CompletionEvent) async throws
}
