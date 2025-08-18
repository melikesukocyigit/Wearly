//
//  SeasonUtils.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 15.08.2025.
//

import UIKit

enum SeasonUtils {
    static func isCompatible(_ seasons: [String]) -> Bool {
        let s = seasons.map { $0.lowercased() }
        if s.contains("all seasons") { return true }
        let counts = Dictionary(grouping: s, by: { $0 }).mapValues(\.count)
        return (counts.values.max() ?? 0) >= 2  
    }

    static func score3(_ t: String, _ b: String, _ s: String) -> CGFloat {
        let arr = [t,b,s].map { $0.lowercased() }
        if arr.contains("all seasons") { return 0.8 }
        let counts = Dictionary(grouping: arr, by: { $0 }).mapValues(\.count)
        switch counts.values.max() ?? 1 {
        case 3: return 1.0
        case 2: return 0.6
        default: return 0.2
        }
    }
}
