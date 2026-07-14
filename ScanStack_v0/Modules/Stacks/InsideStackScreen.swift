//
//  InsideStackScreen.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 13/07/2026.
//

import SwiftUI

struct InsideStackScreen: View {
    let stack: StackGroup
    @Environment(\.dismiss) private var dismiss
    @State private var sortNewest = true
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // Sorted documents based on toggle
    private var sortedDocuments: [ScannedDocument] {
        if sortNewest {
            return stack.documents.sorted { ($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast) }
        } else {
            return stack.documents.sorted { ($0.dateCreated ?? .distantPast) < ($1.dateCreated ?? .distantPast) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            
            // MARK: - Top Bar
            HStack {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Stack Title
                Text(stack.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Sort Button
                Button {
                    withAnimation {
                        sortNewest.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.black)
            
            // MARK: - Image Grid
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // Photo Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(sortedDocuments, id: \.id) { doc in
                            NavigationLink(destination: ImagePreview(document: doc)) {
                                ImageThumbnailView(document: doc)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Page dots indicator (placeholder for future pagination)
                    HStack(spacing: 6) {
                        ForEach(0..<min(5, max(1, sortedDocuments.count / 9 + 1)), id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Ads Placeholder
                    AdsPlaceholderView()
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 4)
            }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Image Thumbnail View (grid cell)
struct ImageThumbnailView: View {
    let document: ScannedDocument
    
    private var thumbnail: UIImage? {
        guard let imageName = document.imageName else { return nil }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName)
        return UIImage(contentsOfFile: path.path)
    }
    
    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Group {
                    if let image = thumbnail {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.15)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.4))
                            )
                    }
                }
            )
            .clipped()
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    InsideStackScreen(stack: StackGroup(name: "My Favorite", documents: []))
}
