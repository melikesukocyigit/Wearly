//
//  FeatureExtractor.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 14.08.2025.
//
import UIKit
import Vision

final class FeatureExtractor {
    static let shared = FeatureExtractor()
    private init() {}

    private var cache: [String: VNFeaturePrintObservation] = [:]
    
    // Kuyruğa, hata ayıklama (debugging) ve performans analizi araçlarında (örneğin Xcode'un Debug Navigator'ı veya Instruments) kolayca tanınabilmesi için benzersiz bir etiket verir. Bu, "Bu iş wearly uygulamasının featureExtractor'ına ait kuyrukta çalışıyor" demenin bir yoludur.

    private let processingQueue = DispatchQueue(label: "com.wearly.featureExtractorQueue")

    func feature(of item: ClothingItem) -> VNFeaturePrintObservation? {
        let key = item.imageFilename
        if let cachedObservation = cache[key] {
            return cachedObservation
        }
        
        guard let uiImage = item.image , let cgImage = uiImage.cgImage else { return nil }

        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            if let observation = request.results?.first as? VNFeaturePrintObservation {
                cache[key] = observation
                return observation
            }
        } catch {
            print("Özellik vektörü hesaplanırken hata oluştu: \(error)")
        }
        
        return nil
    }

    func distance(_ a: VNFeaturePrintObservation, _ b: VNFeaturePrintObservation) -> Float {
        var dist: Float = 0
        do {
            try a.computeDistance(&dist, to: b)
            return dist
        } catch {
            return Float.greatestFiniteMagnitude
        }
    }
    
 
    func warmCache(items: [ClothingItem]) {
        processingQueue.async {
            for item in items {
                // Fonksiyonu sadece önbelleği doldurma yan etkisi için çağırıyoruz.
                _ = self.feature(of: item)
            }
            print("Önbellek ısıtma işlemi tamamlandı.")
        }
    }
}
