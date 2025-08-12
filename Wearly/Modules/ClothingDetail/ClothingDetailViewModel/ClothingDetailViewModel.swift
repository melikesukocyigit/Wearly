import UIKit

final class ClothingDetailViewModel {
    private let item: ClothingItem

    init(item: ClothingItem) {
        self.item = item
    }

    var id: UUID { item.id }
    var image: UIImage? { item.image }
    var categoryText: String { item.category.rawValue }
    var seasonText: String { item.season }
    var colorHex: String { item.color }

    func color() -> UIColor {
        UIColor(hex: item.color) ?? .systemGray3
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6,
              let r = UInt8(s.prefix(2), radix: 16),
              let g = UInt8(s.dropFirst(2).prefix(2), radix: 16),
              let b = UInt8(s.suffix(2), radix: 16) else { return nil }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
}

