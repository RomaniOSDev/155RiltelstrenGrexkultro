//
//  ReflectionModels.swift
//  155RiltelstrenGrexkultro
//

import Foundation

enum ReflectionMood: String, Codable, CaseIterable, Identifiable {
    case great
    case ok
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .great: return "Great"
        case .ok: return "OK"
        case .hard: return "Tough"
        }
    }

    var symbolName: String {
        switch self {
        case .great: return "face.smiling"
        case .ok: return "checkmark.circle.fill"
        case .hard: return "cloud.rain"
        }
    }
}

struct DiaryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let recordedAt: Date
    let mood: ReflectionMood
    let note: String
    let challengeTitle: String

    init(
        id: UUID = UUID(),
        recordedAt: Date = .now,
        mood: ReflectionMood,
        note: String,
        challengeTitle: String
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.mood = mood
        self.note = note
        self.challengeTitle = challengeTitle
    }
}

struct ScenarioDayMark: Codable, Equatable {
    let dayKey: String
    let scenarioRaw: String
}
