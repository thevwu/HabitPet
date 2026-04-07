////
//	HabitPet
//	PetRepository.swift
//
//	Created by: thevwu on 2026
//

import Foundation

protocol PetRepository: Sendable {
	func fetchPet() async throws -> Pet?
	func savePet(_ pet: Pet) async throws
	func seedIfNeeded(now: Date, bootstrap: HomeBootstrap?) async throws
}
