//
//  CombinationEngine.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 14.08.2025.
//

import UIKit
import Vision
import CoreGraphics

struct Weights {
    var style: CGFloat = 0.6
    var color: CGFloat = 0.3
    var season: CGFloat = 0.1
}

struct CombinationSuggestion: Hashable {
    let top: ClothingItem
    let bottom: ClothingItem
    let shoes: ClothingItem
    let score: CGFloat
}

final class CombinationEngine {
    private let fx = FeatureExtractor.shared
    private let w: Weights
    private let strictSeason: Bool

    init(weights: Weights = .init(), strictSeason: Bool = true) {
        self.w = weights
        self.strictSeason = strictSeason
    }
    func topK(from items: [ClothingItem], k: Int = 10) -> [CombinationSuggestion] {
        let tops = items.filter { $0.category == .tops }
        let bottoms = items.filter { $0.category == .bottoms }
        let shoes = items.filter { $0.category == .shoes }
        guard !tops.isEmpty, !bottoms.isEmpty, !shoes.isEmpty else { return [] }

        var fcache: [UUID: VNFeaturePrintObservation] = [:]
        func f(_ item: ClothingItem) -> VNFeaturePrintObservation? {
            if let got = fcache[item.id] { return got }
            guard let obs = fx.feature(of: item) else { return nil }
            fcache[item.id] = obs
            return obs
        }

        var results: [CombinationSuggestion] = []

        for t in tops {
            guard let ft = f(t) else { continue }
            for b in bottoms {
                guard let fb = f(b) else { continue }
                for s in shoes {
                    guard let fs = f(s) else { continue }

                    if strictSeason && !SeasonUtils.isCompatible([t.season, b.season, s.season]) {
                        continue
                    }

        
                    let style  = ScoreUtils.styleScore3(ft, fb, fs, using: fx)
                    let color  = ColorUtils.colorScore3(t.color, b.color, s.color)
                    let season = SeasonUtils.score3(t.season, b.season, s.season)
                    let total = ScoreUtils.total(style: style, color: color, season: season, w: w)

                    results.append(.init(top: t, bottom: b, shoes: s, score: total))
                }
            }
        }

        return results
            .sorted { $0.score > $1.score }
            .prefix(k)
            .map { $0 }
    }

}
