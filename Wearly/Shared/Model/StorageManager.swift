import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private init() {}

    var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    @discardableResult
    func save(image: UIImage) -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = documentsURL.appendingPathComponent(filename)
        let data = image.jpegData(compressionQuality: 0.9) ?? Data()
        try? data.write(to: url, options: .atomic)
        return filename
    }

    func delete(imageFilename: String) {
        let url = documentsURL.appendingPathComponent(imageFilename)
        try? FileManager.default.removeItem(at: url)
    }
}


