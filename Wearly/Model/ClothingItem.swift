//
//  ClothingItem.swift
//  OOtdays
//
//  Created by Melike Su KOÇYİĞİT on 6.08.2025.
//

import Foundation


enum ClothingCategory: String, Codable, CaseIterable
{
    case tops = "Tops"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    case accessories = "Accessories"
}

struct ClothingItem: Codable
{
    let name: String
    let category: ClothingCategory
    let season: String
    let color: String
}



