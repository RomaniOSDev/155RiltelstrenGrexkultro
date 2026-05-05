//
//  WinterTripTemplate.swift
//  155RiltelstrenGrexkultro
//

import Foundation

enum WinterTripTemplate: String, CaseIterable, Identifiable, Hashable {
    case cityDay
    case trailWeekend

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cityDay: return "Day in the city"
        case .trailWeekend: return "Trail weekend"
        }
    }

    var blurb: String {
        switch self {
        case .cityDay: return "Cafe hops, transit, and wind tunnels—light shell top priority."
        case .trailWeekend: return "Elevation chill and mud—warm base, traction footwear, packable insulation."
        }
    }

    /// Piece ids placed into each layer (order: outerwear, accessories, base)
    var layout: [WardrobeLayer: [String]] {
        switch self {
        case .cityDay:
            return [
                .outerwear: ["shell", "parka"],
                .accessories: ["scarf", "beanie", "boots"],
                .base: ["fleece", "therm"]
            ]
        case .trailWeekend:
            return [
                .outerwear: ["parka", "shell"],
                .accessories: ["glove", "socks", "boots"],
                .base: ["therm", "fleece"]
            ]
        }
    }
}
