////
//	HabitPet
//	NSManagedObjectContext+Async.swift
//
//	Created by: thevwu on 2026
//

import CoreData
import Foundation

extension NSManagedObjectContext {
	func performAsync<T: Sendable>(
		_ work: @escaping @Sendable (NSManagedObjectContext) throws -> T
	) async throws -> T {
		try await withCheckedThrowingContinuation { continuation in
			self.perform {
				do {
					let value = try work(self)
					continuation.resume(returning: value)
				} catch is CancellationError {
					continuation.resume(throwing: AppError.cancelled)
				} catch {
					continuation.resume(throwing: AppError.from(error))
				}
			}
		}
	}

	func saveIfNeeded() throws {
		if hasChanges {
			do {
				try save()
			} catch {
				throw AppError.persistence(message: error.localizedDescription)
			}
		}
	}
}
