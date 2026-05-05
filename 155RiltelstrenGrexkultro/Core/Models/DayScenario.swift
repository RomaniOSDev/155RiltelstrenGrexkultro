//
//  DayScenario.swift
//  155RiltelstrenGrexkultro
//

import Foundation

enum DayScenario: String, CaseIterable, Identifiable, Hashable, Codable {
    case clear
    case windy
    case rain
    case coldSnap
    case heat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clear: return "Clear"
        case .windy: return "Windy"
        case .rain: return "Rain"
        case .coldSnap: return "Cold snap"
        case .heat: return "Heat"
        }
    }

    var symbolName: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .windy: return "wind"
        case .rain: return "cloud.rain.fill"
        case .coldSnap: return "snowflake"
        case .heat: return "thermometer.sun.fill"
        }
    }

    var shortTip: String {
        switch self {
        case .clear: return "Bright contrast—plan layers you can peel."
        case .windy: return "Secure loose items; favor sheltered loops."
        case .rain: return "Quick-dry shells; shorten outdoor segments."
        case .coldSnap: return "Double base layers; mind fingers and ears."
        case .heat: return "Hydrate early; pick shade breaks on long walks."
        }
    }
}
