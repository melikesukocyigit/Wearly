import UIKit
import CoreImage

final class AddClothingViewModel {

    private(set) var capturedImage: UIImage?
    private(set) var selectedCategory: ClothingCategory = .tops
    private(set) var selectedSeason: String = "All Seasons"
    private(set) var selectedColorIndex: Int?
    private(set) var selectedColorHex: String?

    let seasons = ["Spring", "Summer", "Autumn", "Winter", "All Seasons"]
    
    let staticColors: [String] = [
        "#FFFFFF","#000000","#808080","#F5F5DC","#FF0000","#000080","#87CEEB","#008000",
        "#FFD700","#8B4513","#FFA500","#800080","#FFC0CB","#A52A2A","#00CED1","#2E8B57",
        "#B0C4DE","#DC143C","#FF7F50","#40E0D0","#ADD8E6","#556B2F","#B22222","#708090"
    ]
    var onImageUpdate: ((UIImage?) -> Void)?
    var onPredictionUpdate: ((ClothingCategory) -> Void)?
    var onColorUpdate: ((String, UIColor) -> Void)?
    var onSaveEnabled: ((Bool) -> Void)?

    func setImage(_ image: UIImage) {
        capturedImage = image
        onImageUpdate?(image)
        validateSave()
    }
    
    func setCategory(_ cat: ClothingCategory) {
        selectedCategory = cat
        onPredictionUpdate?(cat)
        validateSave()
    }
    
    func setSeason(_ s: String) {
        selectedSeason = s
        validateSave()
    }

    func selectColor(at index: Int) {
        guard staticColors.indices.contains(index) else { return }
        selectedColorIndex = index
        selectedColorHex = staticColors[index]
        let color = uiColor(from: selectedColorHex ?? "#808080") ?? .systemGray3
        onColorUpdate?(selectedColorHex ?? "#808080", color)
        validateSave()
    }
    func uiColor(from hex: String) -> UIColor? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6,
              let r = UInt8(s.prefix(2), radix: 16),
              let g = UInt8(s.dropFirst(2).prefix(2), radix: 16),
              let b = UInt8(s.suffix(2), radix: 16) else { return nil }
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }

    func averageHex(from image: UIImage) -> String? {
        guard let ci = CIImage(image: image) else { return nil }
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ci,
            kCIInputExtentKey: CIVector(cgRect: ci.extent)
        ])
        let ctx = CIContext(options: [.workingColorSpace: NSNull()])
        guard
            let out = filter?.outputImage,
            let cg  = ctx.createCGImage(out, from: CGRect(x: 0, y: 0, width: 1, height: 1)),
            let data = cg.dataProvider?.data,
            let ptr = CFDataGetBytePtr(data)
        else { return nil }
        let r = Int(ptr[0]), g = Int(ptr[1]), b = Int(ptr[2])
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    func nearestPaletteIndex(to hex: String) -> Int? {
        func rgb(_ hex: String) -> (Int, Int, Int)? {
            var s = hex.uppercased()
            if s.hasPrefix("#") { s.removeFirst() }
            guard s.count == 6,
                  let r = Int(s.prefix(2), radix: 16),
                  let g = Int(s.dropFirst(2).prefix(2), radix: 16),
                  let b = Int(s.suffix(2), radix: 16) else { return nil }
            return (r,g,b)
        }
        guard let (r1,g1,b1) = rgb(hex) else { return nil }
        var bestIdx: Int?
        var bestDist = Int.max
        for (i, h) in staticColors.enumerated() {
            guard let (r2,g2,b2) = rgb(h) else { continue }
            let d = (r1 - r2)*(r1 - r2) + (g1 - g2)*(g1 - g2) + (b1 - b2)*(b1 - b2)
            if d < bestDist { bestDist = d; bestIdx = i }
        }
        return bestIdx
    }

    @discardableResult //ignorinf return values
    func autoPickNearestColorForCurrentImage() -> (Int?, String?) {
        guard let img = capturedImage,
              let avg = averageHex(from: img),
              let idx = nearestPaletteIndex(to: avg) else {
            return (nil, nil)
        }
        selectColor(at: idx)
        return (idx, staticColors[idx])
    }
    
    func buildPayload(name: String?) -> (image: UIImage, name: String, category: ClothingCategory, season: String, colorHex: String)? {
        guard let img = capturedImage else { return nil }
        let finalName = (name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? name! : selectedCategory.rawValue
        let hex = selectedColorHex ?? "#808080"
        return (img, finalName, selectedCategory, selectedSeason, hex)
    }

    private func validateSave() {
        let ok = (capturedImage != nil)
        onSaveEnabled?(ok)
    }
}


