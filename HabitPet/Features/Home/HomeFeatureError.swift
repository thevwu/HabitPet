////
//	HabitPet
//	HomeFeatureError.swift
//
//	Created by: thevwu on 2026
//


import Foundation

enum HomeFeatureError: Error, Equatable, LocalizedError, Sendable {
    case loadFailed(AppError)
    case completionFailed(AppError)

    var errorDescription: String? {
        switch self {
        case let .loadFailed(error):
            return error.errorDescription ?? "Failed to load Home."
        case let .completionFailed(error):
            return error.errorDescription ?? "Failed to save completion."
        }
    }
}