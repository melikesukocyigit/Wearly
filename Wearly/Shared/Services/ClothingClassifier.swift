import UIKit

final class ClothingClassifier {
    func classify(image: UIImage, completion: @escaping (String) -> Void) {
        // Burada gerçek CoreML çağrını yapabilirsin.
        // Şimdilik örnek amaçlı sabit bir etiket dönelim:
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            completion("tops")
        }
    }

    func mapLabelToCategory(_ label: String) -> ClothingCategory {
        switch label.lowercased() {
        case "tops", "tshirt", "shirt", "sweater": return .tops
        case "bottoms", "pants", "skirt", "shorts": return .bottoms
        case "shoes", "sneakers", "boots": return .shoes
        case "accessories", "bag", "belt", "hat": return .accessories
        default: return .tops
        }
    }
}

