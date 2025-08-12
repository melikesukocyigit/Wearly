import UIKit

final class WardrobeViewModel {

    // Outputs
    var onItemsChanged: (([ClothingItem]) -> Void)?
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?

    // State
    private(set) var allItems: [ClothingItem] = [] {
        didSet { onItemsChanged?(filteredItems) }
    }
    private(set) var selectedCategory: ClothingCategory = .tops {
        didSet { onItemsChanged?(filteredItems) }
    }

    private var itemsURL: URL {
        StorageManager.shared.documentsURL.appendingPathComponent("wardrobe.json")
    }

    var filteredItems: [ClothingItem] {
        allItems.filter { $0.category == selectedCategory }
    }

    // Intents
    func updateCategory(to category: ClothingCategory) {
        selectedCategory = category
        onDataChanged?()
    }

    func add(image: UIImage, name: String, category: ClothingCategory, season: String, color: String) {
        let filename = StorageManager.shared.save(image: image)
        let item = ClothingItem(
            id: UUID(),
            imageFilename: filename,
            name: name,
            category: category,
            season: season,
            color: color
        )
        allItems.append(item)
        saveToDisk()
        onDataChanged?()
    }

    func remove(itemID: UUID) {
        guard let idx = allItems.firstIndex(where: { $0.id == itemID }) else { return }
        StorageManager.shared.delete(imageFilename: allItems[idx].imageFilename)
        allItems.remove(at: idx)
        saveToDisk()
        onDataChanged?()
    }

    // Persistence
    func loadFromDisk() {
        do {
            let data = try Data(contentsOf: itemsURL)
            allItems = try JSONDecoder().decode([ClothingItem].self, from: data)
        } catch {
            allItems = []
        }
        onDataChanged?()
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(allItems)
            try data.write(to: itemsURL, options: [.atomic])
        } catch {
            onError?("Kayıt sırasında hata: \(error.localizedDescription)")
        }
    }
}

