////
//	HabitPet
//	Pet.swift
//
//	Created by: thevwu on 2026
//

import Foundation

struct Pet: Equatable, Identifiable {
	let id: UUID
	var name: String
	var type: PetType
	var mood: PetMood
	var energy: Int
	var affection: Int

	static let mock = Pet(
		id: UUID(),
		name: "Mochi",
		type: .dog,
		mood: .neutral,
		energy: 65,
		affection: 60
	)
}

enum PetType: String, Equatable, CaseIterable {
	case dog
	case cat
	case bird
	case plant
}

enum PetMood: Equatable {
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
