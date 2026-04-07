////
//	HabitPet
//	AppError.swift
//
//	Created by: thevwu on 2026
//


import Foundation

enum AppError: Error, Equatable, LocalizedError, Sendable {
    case notFound(entity: String)
    case persistence(message: String)
    case mapping(message: String)
    case repository(message: String)
    case cancelled
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case let .notFound(entity):
            return "\(entity) was not found."
        case let .persistence(message):
            return "Persistence error: \(message)"
        case let .mapping(message):
            return "Mapping error: \(message)"
        case let .repository(message):
            return "Repository error: \(message)"
        case .cancelled:
            return "The operation was cancelled."
        case let .unknown(message):
            return "Unexpected error: \(message)"
        }
    }
}

extension AppError {
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if error is CancellationError {
            return .cancelled
        }

        return .unknown(message: error.localizedDescription)
    }
}