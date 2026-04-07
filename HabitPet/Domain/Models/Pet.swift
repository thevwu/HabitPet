////
//	HabitPet
//	Pet.swift
//
//	Created by: thevwu on 2026
//

import Foundation

struct Pet: Equatable, Identifiable, Sendable {
	let id: UUID
	var name: String
	var type: PetType
	var mood: PetMood
	var energy: Int
	var affection: Int
	var syncMetadata: SyncMetadata

	static func seeds(now: Date) -> Pet {
		Pet(
			id: UUID(),
			name: "Mochi",
			type: .dog,
			mood: .neutral,
			energy: 65,
			affection: 60,
			syncMetadata: .fresh(now: now)
		)
	}
}

enum PetType: String, Equatable, Codable, CaseIterable, Sendable {
	case dog
	case cat
	case bird
	case plant
}

enum PetMood: String, Equatable, Codable, Sendable {
	case joyful
	case energetic
	case neutral
	case worried
	case sleepy

	var displayName: String {
		switch self {
		case .joyful: return "Joyful"
		case .energetic: return "Energetic"
		case .neutral: return "Neutral"
		case .worried: return "Worried"
		case .sleepy: return "Sleepy"
		}
	}

	var emoji: String {
		switch self {
		case .joyful: return "🐶"
		case .energetic: return "⚡️"
		case .neutral: return "🙂"
		case .worried: return "🥺"
		case .sleepy: return "😴"
		}
	}
}
