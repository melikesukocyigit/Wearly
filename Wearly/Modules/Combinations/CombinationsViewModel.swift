//
//  CombinationsViewModel.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 14.08.2025.
//

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

    // MARK: - Ranking / Config
    var topK: Int = 50                         // shuffle havuzu daha geniş olsun
    var weights: Weights
    var strictSeason: Bool

    // Shuffle davranışı (yüksek skorlar biraz daha şanslı olsun diye)
    var gamma: CGFloat = 1.3                   // 1.0 = hafif, 2.0 = yüksek skor bias

    // MARK: - Shuffle state
    private var pool: [CombinationSuggestion] = []       // engine.topK havuzu
    private var recentlyShown: Set<CombinationSuggestion> = []
    private let recentLimit = 10
    private(set) var current: CombinationSuggestion?     // ekranda gösterilen son kombin

    // (Opsiyonel) sürpriz modu bayrağı (şimdilik kullanılmıyor)
    var surpriseMode: Bool = false

    // MARK: - Init
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

    // MARK: - Deterministic suggestions (liste isteyen yerler için)
    func suggest() -> [CombinationSuggestion] {
        let items = wardrobeProvider()
        return engine.topK(from: items, k: topK)
    }

    /// Eski tekli deterministik seçim (ilk taze olan); artık shuffleNext kullanmanı öneririm.
    func nextSuggestion() -> CombinationSuggestion? {
        let items = wardrobeProvider()
        let candidates = engine.topK(from: items, k: topK)
        guard !candidates.isEmpty else { return nil }

        if let fresh = candidates.first(where: { !recentlyShown.contains($0) }) {
            remember(fresh)
            current = fresh
            return fresh
        }

        recentlyShown.removeAll()
        let pick = candidates.first!
        remember(pick)
        current = pick
        return pick
    }

    // MARK: - Shuffle havuz yönetimi
    func refreshPool() {
        let items = wardrobeProvider()
        pool = engine.topK(from: items, k: topK)
        recentlyShown.removeAll()
        current = nil
    }

    // Ağırlıklı rastgele seçim: weight = score^gamma
    private func pickWeightedRandom(from list: [CombinationSuggestion]) -> CombinationSuggestion? {
        guard !list.isEmpty else { return nil }

        let weights = list.map { pow(Double($0.score), Double(gamma)) }
        let total = weights.reduce(0, +)
        if total <= 0 {
            return list.randomElement() // fallback: uniform
        }

        let r = Double.random(in: 0..<total)
        var acc = 0.0
        for (i, w) in weights.enumerated() {
            acc += w
            if r < acc { return list[i] }
        }
        return list.last
    }

    /// Kullanıcı "Yeni"ye bastığında çağır: havuzdan tekrarsız, ağırlıklı rastgele bir kombin seçer.
    func shuffleNext() -> CombinationSuggestion? {
        if pool.isEmpty { refreshPool() }

        // tekrarsız adaylar
        var candidates = pool.filter { !recentlyShown.contains($0) }
        if candidates.isEmpty {
            // tüm havuz görüldü → hafızayı sıfırla
            recentlyShown.removeAll()
            candidates = pool
        }

        guard let pick = pickWeightedRandom(from: candidates) else { return nil }
        current = pick
        remember(pick)
        return pick
    }

    private func remember(_ s: CombinationSuggestion) {
        recentlyShown.insert(s)
        if recentlyShown.count > recentLimit, let any = recentlyShown.randomElement() {
            recentlyShown.remove(any)
        }
    }

    // MARK: - Like / Favorites
    enum LikeResult { case added, already, noCurrent }

    /// Ekrandaki mevcut kombin favorilere kaydedilir.
    func likeCurrent() -> LikeResult {
        guard let s = current else { return .noCurrent }
        let fav = FavoriteCombination(
            topID: s.top.id,
            bottomID: s.bottom.id,
            shoesID: s.shoes.id,
            score: Double(s.score)
        )
        let ok = FavoritesStore.shared.addIfNeeded(fav)
        return ok ? .added : .already
    }
}
