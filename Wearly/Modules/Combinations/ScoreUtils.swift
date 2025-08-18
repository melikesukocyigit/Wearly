//
//  ScoreUtils.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 15.08.2025.
//

import Vision
import CoreGraphics

enum ScoreUtils {
    static func styleScore3(_ ft: VNFeaturePrintObservation,
                            _ fb: VNFeaturePrintObservation,
                            _ fs: VNFeaturePrintObservation,
                            using fx: FeatureExtractor = .shared) -> CGFloat {
        let dtb = fx.distance(ft, fb)
        let dts = fx.distance(ft, fs)
        let dbs = fx.distance(fb, fs)
        let avg = CGFloat((dtb + dts + dbs) / 3.0)
        let dmax: CGFloat = 1.5
        let s = 1 - min(1, max(0, avg / dmax))
        return s
    }

    static func total(style: CGFloat, color: CGFloat, season: CGFloat, w: Weights) -> CGFloat {
        max(0, min(1, w.style*style + w.color*color + w.season*season))
    }
}
