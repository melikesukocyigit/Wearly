//
//  CombinationsViewModel.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 14.08.2025.
//

import UIKit
import CoreGraphics

final class CombinationsViewModel {

    private let wardrobeProvider: () -> [ClothingItem]
    private var engine: CombinationEngine
    private var recentlyShown: Set<CombinationSuggestion> = []
    private let recentLimit = 8

    // (Opsiyonel) sürpriz modu için ağırlıklı rastgele
    var surpriseMode: Bool = false

    var topK: Int = 10
    var weights: Weights
    var strictSeason: Bool

    init(wardrobeProvider: @escaping () -> [ClothingItem],
         weights: Weights = Weights(style: 0.6, color: 0.3, season: 0.1),
         strictSeason: Bool = true) {
        self.wardrobeProvider = wardrobeProvider
        self.weights = weights
        self.strictSeason = strictSeason
        self.engine = CombinationEngine(weights: weights, strictSeason: strictSeason)
    }

    func updateEngine() {
        engine = CombinationEngine(weights: weights, strictSeason: strictSeason)
    }

    func suggest() -> [CombinationSuggestion] {
        let items = wardrobeProvider()
        return engine.topK(from: items, k: topK)
    }
    func nextSuggestion() -> CombinationSuggestion? {
        let items = wardrobeProvider()
        let candidates = engine.topK(from: items, k: topK)
        guard !candidates.isEmpty else { return nil }

        // 1) Daha önce gösterilmeyenlerden birini seç
        if let fresh = candidates.first(where: { !recentlyShown.contains($0) }) {
            remember(fresh)
            return fresh
        }

        // 2) Hepsi gösterildiyse hafızayı sıfırla ve en iyisini ver
        recentlyShown.removeAll()
        let pick = candidates.first!
        remember(pick)
        return pick
    }

    private func remember(_ s: CombinationSuggestion) {
        recentlyShown.insert(s)
        if recentlyShown.count > recentLimit {
            // Küçük bir temizlik: en düşük skorlu olanı at
            if let worst = recentlyShown.min(by: { $0.score < $1.score }) {
                recentlyShown.remove(worst)
            }
        }
    }

}
