//
//  FavoritesViewModel.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 18.08.2025.
//

import UIKit

struct FavoriteUIItem: Hashable {
    let id: String              
    let topImageName: String
    let bottomImageName: String
    let shoesImageName: String
    let score: Double
}

final class FavoritesViewModel {

    // Wardrobe’daki dosya adından UIImage’a ulaşmak için bu closure’ı enjekte edeceğiz
    private let imageLoader: (String) -> UIImage?

    init(imageLoader: @escaping (String) -> UIImage?) {
        self.imageLoader = imageLoader
    }

    private(set) var items: [FavoriteUIItem] = []

    func load(completion: @escaping () -> Void) {
        FavoritesRepository.shared.fetchAll { list in
            // FavoriteCombination → FavoriteUIItem
            self.items = list.map { fav in
                FavoriteUIItem(
                    id: "\(fav.topID.uuidString)-\(fav.bottomID.uuidString)-\(fav.shoesID.uuidString)",
                    topImageName: fav.topImageFilename,
                    bottomImageName: fav.bottomImageFilename,
                    shoesImageName: fav.shoesImageFilename,
                    score: fav.score
                )
            }
            completion()
        }
    }

    func image(for filename: String) -> UIImage? {
        imageLoader(filename)
    }
}
