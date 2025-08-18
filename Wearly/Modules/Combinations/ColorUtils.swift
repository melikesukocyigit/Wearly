//
//  ColorUtils.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 15.08.2025.
//

import CoreGraphics

enum ColorUtils {
    
    static func hexToRGB(_ hex: String) -> (CGFloat, CGFloat, CGFloat)? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        let r = CGFloat((v >> 16) & 0xFF) / 255.0
        let g = CGFloat((v >> 8)  & 0xFF) / 255.0
        let b = CGFloat(v & 0xFF) / 255.0
        return (r,g,b)
    }

    static func colorDistance(_ hex1: String, _ hex2: String) -> CGFloat {
        guard let a = hexToRGB(hex1), let b = hexToRGB(hex2) else { return 1 }
        let dr = a.0 - b.0, dg = a.1 - b.1, db = a.2 - b.2
        return sqrt(dr*dr + dg*dg + db*db)
    }

    static func colorScore3(_ top: String, _ bottom: String, _ shoes: String) -> CGFloat {
        let dTB = colorDistance(top, bottom)
        let dTS = colorDistance(top, shoes)
        let dBS = colorDistance(bottom, shoes)
        let avg = (dTB + dTS + dBS) / 3.0
        let maxDist: CGFloat = 1.732 // ~sqrt(3)
        let score = 1 - min(1, max(0, avg / maxDist))
        return score
    }
}
