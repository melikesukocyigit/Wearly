//
//  FavoriteCombination.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 18.08.2025.
//
import Foundation

struct FavoriteCombination: Codable, Hashable {
    let id: String            // tekil anahtar: top-bottom-shoes
    let topID: UUID
    let bottomID: UUID
    let shoesID: UUID
    let score: Double
    let createdAt: Date

    static func makeID(top: UUID, bottom: UUID, shoes: UUID) -> String {
        return "\(top.uuidString)-\(bottom.uuidString)-\(shoes.uuidString)"
    }

    init(topID: UUID, bottomID: UUID, shoesID: UUID, score: Double) {
        self.topID = topID
        self.bottomID = bottomID
        self.shoesID = shoesID
        self.score = score
        self.createdAt = Date()
        self.id = FavoriteCombination.makeID(top: topID, bottom: bottomID, shoes: shoesID)
    }
}


