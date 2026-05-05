//
//  WinterWardrobeViewModel.swift
//  155RiltelstrenGrexkultro
//

import Combine
import Foundation
import SwiftUI

enum WardrobeLayer: String, CaseIterable, Identifiable {
    case outerwear
    case accessories
    case base

    var id: String { rawValue }

    var title: String {
        switch self {
        case .outerwear: return "Outerwear"
        case .accessories: return "Accessories"
        case .base: return "Base layers"
        }
    }
}

struct WardrobePiece: Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    let layer: WardrobeLayer
}

final class WinterWardrobeViewModel: ObservableObject {
    let difficulty: ActivityDifficulty

    @Published private(set) var tray: [WardrobePiece]
    @Published private(set) var slots: [WardrobeLayer: [WardrobePiece]] = [:]
    @Published var draggedPiece: WardrobePiece?

    private let startedAt = Date()

    init(difficulty: ActivityDifficulty) {
        self.difficulty = difficulty
        tray = WinterWardrobeViewModel.buildTray(for: difficulty)
        slots = Dictionary(uniqueKeysWithValues: WardrobeLayer.allCases.map { ($0, []) })
    }

    private static func fullPiecePool() -> [WardrobePiece] {
        [
            WardrobePiece(id: "shell", title: "Weather shell", symbol: "cloud.rain", layer: .outerwear),
            WardrobePiece(id: "parka", title: "Insulated coat", symbol: "snowflake", layer: .outerwear),
            WardrobePiece(id: "fleece", title: "Mid fleece", symbol: "flame", layer: .base),
            WardrobePiece(id: "therm", title: "Thermal layer", symbol: "tshirt.fill", layer: .base),
            WardrobePiece(id: "beanie", title: "Warm hat", symbol: "hat.cap", layer: .accessories),
            WardrobePiece(id: "glove", title: "Gloves", symbol: "hand.raised", layer: .accessories),
            WardrobePiece(id: "scarf", title: "Scarf", symbol: "wind", layer: .accessories),
            WardrobePiece(id: "socks", title: "Wool socks", symbol: "shoe", layer: .base),
            WardrobePiece(id: "boots", title: "Traction boots", symbol: "figure.walk", layer: .accessories)
        ]
    }

    private static func buildTray(for difficulty: ActivityDifficulty) -> [WardrobePiece] {
        let density = difficulty == .easy ? 9 : (difficulty == .medium ? 7 : 6)
        return Array(fullPiecePool().prefix(density))
    }

    func applyTripTemplate(_ template: WinterTripTemplate) {
        let pool = Self.fullPiecePool()
        var remaining = pool
        var nextSlots: [WardrobeLayer: [WardrobePiece]] = Dictionary(uniqueKeysWithValues: WardrobeLayer.allCases.map { ($0, []) })

        for layer in WardrobeLayer.allCases {
            let ids = template.layout[layer] ?? []
            var placed: [WardrobePiece] = []
            for id in ids {
                if let idx = remaining.firstIndex(where: { $0.id == id }) {
                    let piece = remaining.remove(at: idx)
                    placed.append(piece)
                }
            }
            nextSlots[layer] = placed
        }
        slots = nextSlots
        tray = remaining
    }

    func drop(_ piece: WardrobePiece, into layer: WardrobeLayer) {
        tray = tray.filter { $0.id != piece.id }
        var current = slots[layer] ?? []
        if !current.contains(where: { $0.id == piece.id }) {
            current.append(piece)
        }
        var next = slots
        next[layer] = current
        slots = next
    }

    func remove(piece: WardrobePiece, from layer: WardrobeLayer) {
        var layerItems = slots[layer] ?? []
        layerItems.removeAll { $0.id == piece.id }
        var next = slots
        next[layer] = layerItems
        slots = next
        if !tray.contains(where: { $0.id == piece.id }) {
            tray = tray + [piece]
        }
    }

    var filledLayers: Int {
        WardrobeLayer.allCases.filter { layer in
            !(slots[layer] ?? []).isEmpty
        }.count
    }

    var isReadyToFinish: Bool {
        filledLayers == WardrobeLayer.allCases.count
    }

    func outcome() -> (stars: Int, spread: Int, packingLabel: String, summary: String, duration: Int) {
        let spread = filledLayers
        let elapsed = Int(Date().timeIntervalSince(startedAt).rounded())
        let stars: Int
        if spread == 3 {
            stars = elapsed < (difficulty == .hard ? 420 : 600) ? 3 : 2
        } else if spread == 2 {
            stars = 2
        } else {
            stars = 1
        }
        let packingLabel = "Layers covered \(spread)/3 in \(elapsed)s"
        let summary = "Packed essentials across \(spread) groups with \(difficulty.title) density tray."
        return (stars, spread, packingLabel, summary, elapsed)
    }
}
