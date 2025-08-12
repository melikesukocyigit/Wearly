import UIKit

struct ClothingItem: Codable, Equatable {
    let id: UUID
    let imageFilename: String
    let name: String
    let category: ClothingCategory
    let season: String
    let color: String   

    var image: UIImage? {
        let url = StorageManager.shared.documentsURL.appendingPathComponent(imageFilename)
        return UIImage(contentsOfFile: url.path)
    }
}

