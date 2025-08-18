//
//  FavoritesStore.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 18.08.2025.
//

import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()
    private init() { load() }

    private let defaultsKey = "favorites.v1"
    private var items: [FavoriteCombination] = []

    // Dış API
    func all() -> [FavoriteCombination] {
        return items.sorted { $0.createdAt > $1.createdAt }
    }

    /// Zaten varsa eklemez; eklenirse true döner.
    @discardableResult
    func addIfNeeded(_ fav: FavoriteCombination) -> Bool {
        if contains(id: fav.id) { return false }
        items.append(fav)
        save()
        return true
    }

    func contains(id: String) -> Bool {
        return items.contains(where: { $0.id == id })
    }

    func remove(id: String) {
        items.removeAll { $0.id == id }
        save()
    }

    // Persist
    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([FavoriteCombination].self, from: data) {
            items = decoded
        }
    }
}
