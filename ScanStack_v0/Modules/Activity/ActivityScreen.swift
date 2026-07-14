//
//  ActivityScreen.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 11/07/2026.
//

import SwiftUI
import PhotosUI

struct ActivityScreen: View {
    @StateObject private var viewModel = ScanningViewModel()
    @State private var showScanOptions = false
    
    // Pickers State
    @State private var showCamera = false
    @State private var showSinglePhoto = false
    @State private var showAlbumPhoto = false
    @State private var selectedCameraImage: UIImage? = nil
    
    @State private var selectedSinglePhoto: PhotosPickerItem? = nil
    @State private var selectedAlbumPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Headings
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isScanning ? "AI is sorting" : "AI is ready to sort")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.primary)
                    Text("your gallery")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                }
                .padding(.top, 10)
                
                if !viewModel.isScanning {
                    // MARK: - READY STATE
                    
                    // Smart Extraction Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SMART EXTRACTION")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle")
                                        .foregroundColor(Color("btn_gradiant_color_0"))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("13 new screenshot found")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Start scanning")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.green)
                                )
                        }
                        .padding(16)
                        .background(Color(hex: "F8F9FA"))
                        .cornerRadius(20)
                    }
                    
                    // MARK: - Scan Now Button
                    Button {
                        print("✅ Scan Now button tapped!")
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showScanOptions.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.viewfinder")
                                .font(.system(size: 24))
                            Text("Scan Now")
                                .font(.system(size: 22, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 10)
                    
                    // MARK: - Dropdown Menu (slides down from Scan Now)
                    if showScanOptions {
                        VStack(spacing: 0) {
                            ScanOptionButton(
                                icon: "camera.fill",
                                title: "Camera",
                                subtitle: "Take a real-time photo"
                            ) {
                                print("✅ Camera selected")
                                withAnimation { showScanOptions = false }
                                showCamera = true
                            }
                            
                            Divider().padding(.horizontal, 16)
                            
                            ScanOptionButton(
                                icon: "photo.fill",
                                title: "Photos",
                                subtitle: "Select a single image"
                            ) {
                                print("✅ Photos selected")
                                withAnimation { showScanOptions = false }
                                showSinglePhoto = true
                            }
                            
                            Divider().padding(.horizontal, 16)
                            
                            ScanOptionButton(
                                icon: "rectangle.stack.fill",
                                title: "Album",
                                subtitle: "Select entire album"
                            ) {
                                print("✅ Album selected")
                                withAnimation { showScanOptions = false }
                                showAlbumPhoto = true
                            }
                        }
                        .background(Color(hex: "F8F9FA"))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .transition(.opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95, anchor: .top)))
                    }
                    
                    // Ads Placeholder
                    AdsPlaceholderView()
                    
                } else {
                    // MARK: - SCANNING STATE
                    
                    // Scanning Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scanning \(viewModel.totalItems) new\nscreenshots...")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Estimating \(viewModel.estimatedSecondsRemaining) seconds\nremaining")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color("btn_gradiant_color_1").opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color("btn_gradiant_color_1"))
                                )
                        }
                        
                        // Progress Bar
                        VStack(alignment: .trailing, spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * progressFraction, height: 8)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(Int(progressFraction * 100))% COMPLETE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("btn_gradiant_color_0"))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Ads Placeholder
                    AdsPlaceholderView()
                    
                    // Smart Extraction List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SMART EXTRACTION")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            if viewModel.extractionStats.isEmpty {
                                Text("Extracting items...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                            } else {
                                ForEach(viewModel.extractionStats) { stat in
                                    ExtractionItemRow(
                                        icon: "doc.text", iconColor: Color("btn_gradiant_color_1"),
                                        title: "\(stat.count) new items found",
                                        subtitle: "Organized into \"\(stat.category)\""
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Bottom padding so content doesn't hide behind tab bar
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 24)
        }
        // MARK: - Sheets & Pickers (attached to ScrollView directly)
        .sheet(isPresented: $showCamera) {
            CameraPicker(selectedImage: $selectedCameraImage)
                .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showSinglePhoto, selection: $selectedSinglePhoto, matching: .images)
        .photosPicker(isPresented: $showAlbumPhoto, selection: $selectedAlbumPhotos, maxSelectionCount: 0, matching: .images)
        .onChange(of: selectedCameraImage) { _, newImage in
            if let img = newImage {
                viewModel.processImages([img])
                selectedCameraImage = nil
            }
        }
        .onChange(of: selectedSinglePhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.processImages([image])
                }
                selectedSinglePhoto = nil
            }
        }
        .onChange(of: selectedAlbumPhotos) { _, newItems in
            Task {
                var images: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                if !images.isEmpty {
                    viewModel.processImages(images)
                }
                selectedAlbumPhotos = []
            }
        }
    }
    
    // MARK: - Computed Properties
    private var progressFraction: CGFloat {
        guard viewModel.totalItems > 0 else { return 0 }
        return CGFloat(viewModel.processedItems) / CGFloat(viewModel.totalItems)
    }
}

// MARK: - Helper Views
struct AdsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
                .frame(height: 80)
                .overlay(
                    Text("Ad Space")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.5))
                )
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pink.opacity(0.15))
                .frame(height: 80)
                .overlay(
                    Text("Ad Space")
                        .font(.caption)
                        .foregroundColor(.pink.opacity(0.5))
                )
        }
    }
}

struct ExtractionItemRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.white)
                .frame(width: 48, height: 48)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                )
        }
        .padding(16)
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(20)
    }
}

struct ScanOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0").opacity(0.15), Color("btn_gradiant_color_1").opacity(0.15)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActivityScreen()
}
