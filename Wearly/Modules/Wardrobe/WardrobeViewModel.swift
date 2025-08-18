import UIKit

final class WardrobeViewModel {
    
    var onItemsChanged: (([ClothingItem]) -> Void)?
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var allItems: [ClothingItem] = []
    private(set) var selectedCategory: ClothingCategory = .tops
    
    private var itemsURL: URL {
        StorageManager.shared.documentsURL.appendingPathComponent("wardrobe.json")
    }
    
    var filteredItems: [ClothingItem] {
        allItems.filter { $0.category == selectedCategory }
    }
    
    func loadItems(_ items: [ClothingItem]) {
        allItems = items
        notifyChanges()
    }

    func updateCategory(to category: ClothingCategory) {
        selectedCategory = category
        notifyChanges()
    }
    
    private func notifyChanges() {
        let snapshot = filteredItems
        DispatchQueue.main.async { [weak self] in
            self?.onItemsChanged?(snapshot)
        }
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


