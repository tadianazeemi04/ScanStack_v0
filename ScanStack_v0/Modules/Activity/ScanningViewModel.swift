import Foundation
import CoreML
import Vision
import UIKit
import CoreData
import Combine
import SwiftUI
import Photos

@MainActor
class ScanningViewModel: ObservableObject {
    @Published var isScanning = false
    @Published var totalItems = 0
    @Published var processedItems = 0
    @Published var estimatedSecondsRemaining = 0
    
    // We track extraction stats for the UI
    @Published var extractionStats: [ExtractionStat] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    struct ExtractionStat: Identifiable {
        let id = UUID()
        let category: String
        var count: Int
    }
    
    func scanAllScreenshots() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized || status == .limited else { return }
            
            let fetchOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: fetchOptions)
            
            guard let screenshotsAlbum = smartAlbums.firstObject else { return }
            
            let assetsFetchResult = PHAsset.fetchAssets(in: screenshotsAlbum, options: nil)
            var imagesToProcess: [UIImage] = []
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            // We use synchronous fetching on this background thread to compile the list
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            // Limit to recent 20 for safety against memory crashes on real devices with 10k screenshots, 
            // since we are fetching UIImages directly in memory.
            let limit = min(assetsFetchResult.count, 20)
            
            for i in 0..<limit {
                let asset = assetsFetchResult.object(at: i)
                manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: requestOptions) { image, _ in
                    if let img = image {
                        imagesToProcess.append(img)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.processImages(imagesToProcess)
            }
        }
    }
    
    func processImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        isScanning = true
        totalItems = images.count
        processedItems = 0
        extractionStats = []
        
        var categoryCounts: [String: Int] = [:]
        let startTime = Date()
        
        Task {
            for image in images {
                // 1. CoreML Classification
                let category = await classifyImage(image)
                
                // 2. Vision OCR
                let text = await extractText(from: image)
                
                // 3. Save to Core Data (Synchronous on Main Thread because context is MainQueue)
                saveToCoreData(image: image, category: category, extractedText: text)
                
                // Update Stats
                categoryCounts[category, default: 0] += 1
                
                // Update UI
                self.processedItems += 1
                
                // Update extractionStats for UI, sorted by highest count
                self.extractionStats = categoryCounts.map { ExtractionStat(category: $0.key, count: $0.value) }
                    .sorted(by: { $0.count > $1.count })
                
                // Calculate ETA
                let elapsed = Date().timeIntervalSince(startTime)
                let timePerItem = elapsed / Double(self.processedItems)
                let remainingItems = totalItems - processedItems
                self.estimatedSecondsRemaining = Int(timePerItem * Double(remainingItems))
            }
            
            // Briefly show 100% complete
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isScanning = false
        }
    }
    
    private func classifyImage(_ image: UIImage) async -> String {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let pixelBuffer = image.toCVPixelBuffer() else {
                    continuation.resume(returning: "Uncategorized")
                    return
                }
                
                do {
                    let config = MLModelConfiguration()
                    config.computeUnits = .cpuOnly
                    let model = try ScanStackClassifier_1(configuration: config)
                    let output = try model.prediction(image: pixelBuffer)
                    continuation.resume(returning: output.target)
                } catch {
                    continuation.resume(returning: "Uncategorized")
                }
            }
        }
    }
    
    private func extractText(from image: UIImage) async -> String {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: "")
                return
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    continuation.resume(returning: "")
                    return
                }
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform([request])
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    private func saveToCoreData(image: UIImage, category: String, extractedText: String) {
        // Save image to Documents Directory
        let imageName = UUID().uuidString + ".jpg"
        let path = getDocumentsDirectory().appendingPathComponent(imageName)
        
        var fileSizeKB = 0.0
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: path)
            fileSizeKB = Double(jpegData.count) / 1024.0
        }
        
        let document = ScannedDocument(context: context)
        document.id = UUID()
        document.imageName = imageName
        document.originalPath = path.path
        document.dateCreated = Date()
        document.stackName = category.capitalized // Make it look nice for UI
        document.extractedText = extractedText
        document.imageSizeKB = fileSizeKB
        
        do {
            try context.save()
        } catch {
            print("Error saving to CoreData: \\(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
