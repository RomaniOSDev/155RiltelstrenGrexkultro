//
//  SunnyCollectionsViewModel.swift
//  155RiltelstrenGrexkultro
//

import Combine
import Foundation
import SwiftUI
import PhotosUI

enum SunnyAlbumCategory: String, CaseIterable, Identifiable {
    case landmarks
    case nature
    case smiles

    var id: String { rawValue }

    var title: String {
        switch self {
        case .landmarks: return "Landmarks"
        case .nature: return "Nature"
        case .smiles: return "Smiles"
        }
    }

    var framingHint: String {
        switch self {
        case .landmarks:
            return "Look for leading lines, symmetry, and a clear focal point."
        case .nature:
            return "Layer foreground texture with sky—keep horizons level."
        case .smiles:
            return "Catch genuine expressions; use softer light on faces."
        }
    }

    static let photosPerCategory = 2

    static func slotKey(_ category: SunnyAlbumCategory, index: Int) -> String {
        "\(category.rawValue)_\(index)"
    }
}

final class SunnyCollectionsViewModel: ObservableObject {
    @Published var pickers: [String: PhotosPickerItem?] = [:]
    @Published var previewImages: [String: Image] = [:]
    @Published var isBusy = false

    let difficulty: ActivityDifficulty
    let sessionStartedAt = Date()
    private var tasks: [Task<Void, Never>] = []

    init(difficulty: ActivityDifficulty) {
        self.difficulty = difficulty
        var next: [String: PhotosPickerItem?] = [:]
        for cat in SunnyAlbumCategory.allCases {
            for idx in 0..<SunnyAlbumCategory.photosPerCategory {
                next[SunnyAlbumCategory.slotKey(cat, index: idx)] = nil
            }
        }
        pickers = next
        previewImages = [:]
    }

    func bind(item: PhotosPickerItem?, category: SunnyAlbumCategory, index: Int) {
        let key = SunnyAlbumCategory.slotKey(category, index: index)
        var next = pickers
        next[key] = item
        pickers = next
        var imgs = previewImages
        imgs[key] = nil
        previewImages = imgs
        guard let item else { return }
        let t = Task {
            await load(item: item, storageKey: key)
        }
        tasks.append(t)
    }

    private func load(item: PhotosPickerItem, storageKey: String) async {
        isBusy = true
        defer { isBusy = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            guard let cg = CGImageDecode.image(from: data) else { return }
            let image = Image(cg, scale: 1, orientation: .up, label: Text(""))
            await MainActor.run {
                var next = previewImages
                next[storageKey] = image
                previewImages = next
            }
        } catch {
            await MainActor.run {
                var next = previewImages
                next[storageKey] = nil
                previewImages = next
            }
        }
    }

    var filledSlotCount: Int {
        let keys = allSlotKeys
        return keys.filter { previewImages[$0] != nil }.count
    }

    var totalSlots: Int {
        SunnyAlbumCategory.allCases.count * SunnyAlbumCategory.photosPerCategory
    }

    private var allSlotKeys: [String] {
        SunnyAlbumCategory.allCases.flatMap { cat in
            (0..<SunnyAlbumCategory.photosPerCategory).map { SunnyAlbumCategory.slotKey(cat, index: $0) }
        }
    }

    var isComplete: Bool {
        SunnyAlbumCategory.allCases.allSatisfy { cat in
            (0..<SunnyAlbumCategory.photosPerCategory).allSatisfy { idx in
                previewImages[SunnyAlbumCategory.slotKey(cat, index: idx)] != nil
            }
        }
    }

    func outcome() -> (stars: Int, speedSeconds: Int, diversity: Int, summary: String) {
        let elapsed = Int(Date().timeIntervalSince(sessionStartedAt).rounded())
        let factor = difficulty == .easy ? 1.15 : (difficulty == .hard ? 0.85 : 1.0)
        let adjusted = Int(Double(elapsed) / factor)
        let fastThreshold = 900
        let midThreshold = 1_800

        var categoryScore = 0
        for cat in SunnyAlbumCategory.allCases {
            let filled = (0..<SunnyAlbumCategory.photosPerCategory)
                .filter { previewImages[SunnyAlbumCategory.slotKey(cat, index: $0)] != nil }
                .count
            if filled == 2 {
                categoryScore += 1
            } else if filled == 1 {
                categoryScore += 0
            }
        }

        let diversity = min(3, categoryScore)

        let stars: Int
        if diversity == 3 {
            if adjusted < fastThreshold { stars = 3 }
            else if adjusted < midThreshold { stars = 2 }
            else { stars = 1 }
        } else if diversity == 2 {
            stars = adjusted < midThreshold ? 2 : 1
        } else {
            stars = 1
        }

        let summary = "Album: \(filledSlotCount)/\(totalSlots) frames in \(adjusted)s (\(difficulty.title) pacing)."
        return (stars, adjusted, diversity, summary)
    }
}
