//
//  ImagePreview.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 13/07/2026.
//

import SwiftUI
import CoreData

struct ImagePreview: View {
    // The scanned document data
    let document: ScannedDocument
    
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorited = false
    
    // Controls Overview sheet position
    @State private var showOverview = false
    @State private var dragOffset: CGFloat = 0
    
    // Computed: load the saved image from Documents
    private var savedImage: UIImage? {
        guard let imageName = document.imageName else { return nil }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName)
        return UIImage(contentsOfFile: path.path)
    }
    
    var body: some View {
        ZStack {
            // MARK: - Black Background
            Color.black.ignoresSafeArea()
            
            // MARK: - Full Screen Image
            if let image = savedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Image not found")
                        .foregroundColor(.gray)
                }
            }
            
            // MARK: - Top Bar (Back + Name + Heart)
            VStack {
                HStack {
                    // Back Button
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Image Name
                    Text(document.imageName ?? "Image")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Favorite Button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isFavorited.toggle()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorited ? .red : .white)
                                .scaleEffect(isFavorited ? 1.15 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
            }
            
            // MARK: - Bottom: Overview Button + Swipe Hint
            VStack {
                Spacer()
                
                // Overview pill button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showOverview = true
                    }
                } label: {
                    Text("Overview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                }
                .buttonStyle(.plain)
                
                // Swipe hint
                HStack(spacing: 6) {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Swipe up to see details")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            
            // MARK: - Overview Sheet (slides up from bottom)
            overviewSheet
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Swipe up = negative translation
                    if value.translation.height < -30 && !showOverview {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showOverview = true
                        }
                    }
                    // Swipe down = positive translation
                    if value.translation.height > 30 && showOverview {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showOverview = false
                        }
                    }
                }
        )
    }
    
    // MARK: - Overview Sheet View
    @ViewBuilder
    private var overviewSheet: some View {
        if showOverview {
            // Dim background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showOverview = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    
                    // Overview pill at top
                    Text("Overview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .padding(.bottom, 16)
                    
                    // Scrollable details
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // Image Name
                            OverviewRow(
                                label: "Image Name:",
                                value: document.imageName ?? "Unknown"
                            )
                            
                            overviewDivider
                            
                            // Day Created
                            OverviewRow(
                                label: "Day Created:",
                                value: formattedDate
                            )
                            
                            overviewDivider
                            
                            // Path
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Path:")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    Text(document.originalPath ?? "N/A")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                // Open path button
                                VStack(spacing: 2) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                    Text("open path")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(Color("btn_gradiant_color_1"))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            
                            overviewDivider
                            
                            // Image Size
                            OverviewRow(
                                label: "Image Size:",
                                value: String(format: "%.0f KB", document.imageSizeKB)
                            )
                            
                            overviewDivider
                            
                            // Collection / Stack Name
                            OverviewRow(
                                label: "Collection Name:",
                                value: document.stackName ?? "Uncategorized"
                            )
                            
                            overviewDivider
                            
                            // Extracted Text
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Extracted Text:")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                Text(document.extractedText ?? "No text extracted")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            
                            overviewDivider
                            
                            // Extra bottom spacing
                            Spacer().frame(height: 40)
                        }
                    }
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.65)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
            }
            .transition(.move(edge: .bottom))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showOverview = false
                            }
                        }
                        dragOffset = 0
                    }
            )
        }
    }
    
    // MARK: - Helpers
    private var overviewDivider: some View {
        Divider().padding(.horizontal, 20)
    }
    
    private var formattedDate: String {
        guard let date = document.dateCreated else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy  h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Overview Row Helper
struct OverviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Custom Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    // Preview with mock data
    ImagePreview(document: ScannedDocument())
}
