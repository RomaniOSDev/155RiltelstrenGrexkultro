//
//  BreathingPreset.swift
//  155RiltelstrenGrexkultro
//

import Foundation

enum BreathingPreset: String, CaseIterable, Identifiable, Hashable {
    case calm
    case balanced
    case focus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: return "Calm"
        case .balanced: return "Balanced"
        case .focus: return "Focus"
        }
    }

    var subtitle: String {
        switch self {
        case .calm: return "Longer inhale & exhale"
        case .balanced: return "Classic rhythm"
        case .focus: return "Shorter, brisk pacing"
        }
    }

    /// Base inhale / hold / exhale seconds before difficulty multiplier.
    var inhale: Double {
        switch self {
        case .calm: return 5
        case .balanced: return 4
        case .focus: return 3
        }
    }

    var hold: Double {
        switch self {
        case .calm: return 3
        case .balanced: return 2
        case .focus: return 1
        }
    }

    var exhale: Double {
        switch self {
        case .calm: return 7
        case .balanced: return 6
        case .focus: return 4
        }
    }
}
