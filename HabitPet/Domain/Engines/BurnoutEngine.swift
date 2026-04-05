////
//	HabitPet
//	BurnoutEngine.swift
//
//	Created by: thevwu on 2026
//

import Foundation

enum BurnoutLevel: String, Equatable {
	case none
	case light
	case heavy

	var displayName: String {
		switch self {
		case .none: return "Clear"
		case .light: return "Light"
		case .heavy: return "Heavy"
		}
	}
}

enum BurnoutEngine {
	static func evaluate(
		habits: [Habit],
		tasks: [TaskItem]
	) -> BurnoutLevel {
		let totalEffort =
			habits.reduce(0) { $0 + $1.effort } +
			tasks.reduce(0) { $0 + $1.effort }

		switch totalEffort {
		case 0...6:
			return .none
		case 7...10:
			return .light
		default:
			return .heavy
		}
	}
}
