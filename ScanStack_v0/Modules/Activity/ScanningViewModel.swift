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
        Task {
            // 1. Request authorization
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            
            guard status == .authorized || status == .limited else {
                print("📸 Error: Not authorized to access photo library.")
                return
            }
            
            // 2. Fetch the Screenshots smart album
            let smartAlbums = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil
            )
            
            guard let screenshotsAlbum = smartAlbums.firstObject else {
                print("📸 Error: No Screenshots smart album found.")
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: screenshotsAlbum, options: fetchOptions)
            print("📸 Found \(assets.count) total screenshots in album.")
            
            // 3. Filter out already-scanned assets to prevent duplicates
            let scannedIDs = Set(UserDefaults.standard.stringArray(forKey: "scannedAssetIdentifiers") ?? [])
            var unscannedAssets: [PHAsset] = []
            
            for i in 0..<assets.count {
                let asset = assets.object(at: i)
                if !scannedIDs.contains(asset.localIdentifier) {
                    unscannedAssets.append(asset)
                }
            }
            
            print("📸 \(unscannedAssets.count) new (unscanned) screenshots to process.")
            
            if unscannedAssets.isEmpty {
                print("📸 All screenshots already scanned. Nothing to do.")
                return
            }
            
            // 4. Set up scanning UI — process ALL unscanned screenshots
            let total = unscannedAssets.count
            isScanning = true
            totalItems = total
            processedItems = 0
            extractionStats = []
            
            var categoryCounts: [String: Int] = [:]
            let startTime = Date()
            var newlyScannedIDs: [String] = []
            
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .fast
            
            print("📸 Starting scan of \(total) screenshots (one at a time to save memory)...")
            
            // 5. Process each screenshot ONE AT A TIME to avoid memory crashes
            for i in 0..<total {
                let asset = unscannedAssets[i]
                
                // Fetch the image
                let image: UIImage? = await withCheckedContinuation { continuation in
                    manager.requestImage(
                        for: asset,
                        targetSize: CGSize(width: 1080, height: 1080),
                        contentMode: .aspectFit,
                        options: requestOptions
                    ) { img, info in
                        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                        if !isDegraded {
                            continuation.resume(returning: img)
                        }
                    }
                }
                
                guard let img = image else {
                    print("📸 [\(i+1)/\(total)] Failed to fetch — skipping")
                    self.processedItems += 1
                    continue
                }
                
                // Classify with CoreML
                let category = await classifyImage(img)
                
                // Extract text with Vision OCR
                let text = await extractText(from: img)
                
                // Save to Core Data
                saveToCoreData(image: img, category: category, extractedText: text)
                
                // Mark this asset as scanned
                newlyScannedIDs.append(asset.localIdentifier)
                
                // Update UI stats
                categoryCounts[category, default: 0] += 1
                self.processedItems += 1
                self.extractionStats = categoryCounts.map { ExtractionStat(category: $0.key, count: $0.value) }
                    .sorted(by: { $0.count > $1.count })
                
                // Calculate ETA
                let elapsed = Date().timeIntervalSince(startTime)
                let timePerItem = elapsed / Double(self.processedItems)
                let remaining = total - self.processedItems
                self.estimatedSecondsRemaining = Int(timePerItem * Double(remaining))
                
                print("📸 [\(i+1)/\(total)] Scanned → \(category)")
                
                // Save scanned IDs every 10 images (in case app is killed mid-scan)
                if newlyScannedIDs.count % 10 == 0 {
                    var allIDs = UserDefaults.standard.stringArray(forKey: "scannedAssetIdentifiers") ?? []
                    allIDs.append(contentsOf: newlyScannedIDs)
                    UserDefaults.standard.setValue(allIDs, forKey: "scannedAssetIdentifiers")
                    newlyScannedIDs.removeAll()
                }
            }
            
            // 6. Save any remaining scanned IDs
            if !newlyScannedIDs.isEmpty {
                var allIDs = UserDefaults.standard.stringArray(forKey: "scannedAssetIdentifiers") ?? []
                allIDs.append(contentsOf: newlyScannedIDs)
                UserDefaults.standard.setValue(allIDs, forKey: "scannedAssetIdentifiers")
            }
            
            print("📸 ✅ Done! Scanned \(total) screenshots successfully.")
            
            // Briefly show 100% complete
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isScanning = false
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
            print("Error saving to CoreData: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
