
import Foundation

class WardrobeViewModel {
    private var selectedCategory: ClothingCategory = .tops
    
    private var allItems: [ClothingItem] = [
        ClothingItem(name: "Beyaz Tişört", category: .tops, season: "Summer", color: "White"),
        ClothingItem(name: "Kot Pantolon", category: .bottoms, season: "Autumn", color: "Blue"),
        ClothingItem(name: "Sneakers", category: .shoes, season: "Spring", color: "White"),
        ClothingItem(name: "Şapka", category: .accessories, season: "Summer", color: "Beige")
    ]
    
   
    var filteredItems: [ClothingItem]
    {
        return allItems.filter { $0.category == selectedCategory }
        
    }
    

    func updateCategory(to category: ClothingCategory)
    {
        selectedCategory = category
    }

    var categoryTitles: [String]
    {
        ClothingCategory.allCases.map { $0.rawValue }
    }
}

