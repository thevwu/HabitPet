////
//	HabitPet
//	CompletionEvent.swift
//
//	Created by: thevwu on 2026
//


import Foundation

struct CompletionEvent: Equatable, Identifiable, Sendable {
    let id: UUID
    var itemID: UUID
    var itemType: CompletionItemType
    var completedAt: Date
    var effort: Int
    var syncMetadata: SyncMetadata
}

enum CompletionItemType: String, Equatable, Codable, Sendable {
    case habit
    case task
}