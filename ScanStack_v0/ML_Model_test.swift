//
//  ML_Model_test.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 14/05/2026.
//

import SwiftUI
import PhotosUI
import CoreML
import VideoToolbox
import PhotosUI
import CoreVideo

struct ML_Model_test: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    // AI Results
    @State private var detectedCategory: String = "---"
    @State private var confidenceValue: String = "0%"
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 1. Display Selected Image
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 250)
                        .overlay(Text("Select a Screenshot to Test AI"))
                }

                // 2. AI Category Dashboard
                VStack(spacing: 10) {
                    HStack {
                        Text("AI CATEGORY:")
                            .font(.caption.bold())
                        Spacer()
                        Text(detectedCategory)
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    HStack {
                        Text("CONFIDENCE:")
                            .font(.caption.bold())
                        Spacer()
                        Text(confidenceValue)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)

                // 3. Selection Button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Pick Screenshot", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: selectedItem) { _, _ in
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            self.selectedImage = uiImage
                            runClassification(on: uiImage)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("ScanStack AI Lab")
            .overlay { if isProcessing { ProgressView() } }
        }
    }
    
    func runClassification(on image: UIImage) {
        // Ensure you use the exact size your model was trained on (likely 299x299)
        guard let resizedImage = image.resize(to: CGSize(width: 299, height: 299)),
              let pixelBuffer = resizedImage.toCVPixelBuffer() else {
            return
        }
        
        isProcessing = true

        // Correct background queue syntax
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuOnly // Required for Simulator hardware bypass
                
                let model = try ScanStackClassifier_1(configuration: config)
                
                // Direct prediction to avoid "Inference Context" errors
                let output = try model.prediction(image: pixelBuffer)
                
                DispatchQueue.main.async {
                    // Mapping to your model's specific 'target' outputs
                    self.detectedCategory = output.target.uppercased()
                    
                    if let confidence = output.targetProbability[output.target] {
                        self.confidenceValue = String(format: "%.0f%%", confidence * 100)
                    }
                    self.isProcessing = false
                }
            } catch {
                print("❌ AI Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.detectedCategory = "Error"
                    self.isProcessing = false
                }
            }
        }
    }
}

#Preview {
    ML_Model_test()
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // Draw 'self' into the context to populate it with image data
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func toCVPixelBuffer() -> CVPixelBuffer? {
        // Hardcode the size to exactly what ScanStackClassifier_1 expects
        let modelSize = 224
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, modelSize, modelSize,
                                         kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard status == noErr, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: modelSize,
                                height: modelSize,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: CGFloat(modelSize))
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        // Ensure we draw the image specifically into the 299x299 square
        self.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

        return buffer
    }
}
