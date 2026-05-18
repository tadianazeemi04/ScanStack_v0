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
        // 1. Convert straight to the exact 299x299 buffer your model needs
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("❌ Could not generate Pixel Buffer")
            return
        }
        
        isProcessing = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuOnly // Prevents the Vision framework crash
                
                let model = try ScanStackClassifier_1(configuration: config)
                let output = try model.prediction(image: pixelBuffer)
                
                DispatchQueue.main.async {
                    self.detectedCategory = output.target.uppercased()
                    if let confidence = output.targetProbability[output.target] {
                        self.confidenceValue = String(format: "%.0f%%", confidence * 100)
                    }
                    self.isProcessing = false
                }
            } catch {
                print("❌ Prediction Error: \(error.localizedDescription)")
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
    // We combined resize and buffer creation into one powerful, fail-proof function
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = 299
        let height = 299
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        // 🚨 THE FIX: Draw using Core Graphics directly instead of UIKit 🚨
        if let cgImage = self.cgImage, let ctx = context {
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

        return buffer
    }
}
