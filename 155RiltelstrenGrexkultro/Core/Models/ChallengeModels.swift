//
//  ChallengeModels.swift
//  155RiltelstrenGrexkultro
//

import Foundation

enum ChallengeId: String, CaseIterable, Identifiable {
    case sunnyCollections = "sunny_collections"
    case rainyRejuvenation = "rainy_rejuvenation"
    case winterWardrobe = "winter_wardrobe"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunnyCollections: return "Sunny Collections"
        case .rainyRejuvenation: return "Rainy Day Rejuvenation"
        case .winterWardrobe: return "Winter Wardrobe Wizard"
        }
    }

    var index: Int {
        switch self {
        case .sunnyCollections: return 0
        case .rainyRejuvenation: return 1
        case .winterWardrobe: return 2
        }
    }
}

enum ActivityDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var breathingMultiplier: Double {
        switch self {
        case .easy: return 1.35
        case .medium: return 1.0
        case .hard: return 0.75
        }
    }

    var tapWindowSeconds: Double {
        switch self {
        case .easy: return 1.1
        case .medium: return 0.75
        case .hard: return 0.5
        }
    }

    var breathingLives: Int {
        switch self {
        case .easy: return 5
        case .medium: return 3
        case .hard: return 2
        }
    }
}
