//
//  ImagePreview.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 13/07/2026.
//

import SwiftUI
import CoreData
import Photos

struct ImagePreview: View {
    // The scanned document data
    let document: ScannedDocument
    
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorited = false
    
    // Controls Overview sheet position
    @State private var showOverview = false
    @State private var dragOffset: CGFloat = 0
    
    // Open path dialog & share sheet states
    @State private var showOpenPathDialog = false
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Computed: load the saved image from Documents or originalPath
    private var savedImage: UIImage? {
        if let imageName = document.imageName, !imageName.isEmpty {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(imageName)
            if let img = UIImage(contentsOfFile: path.path) {
                return img
            }
        }
        if let originalPath = document.originalPath, !originalPath.isEmpty {
            if let img = UIImage(contentsOfFile: originalPath) {
                return img
            }
        }
        return nil
    }
    
    // Computed: resolve local file URL for sharing / file manager
    private var fileURL: URL? {
        if let imageName = document.imageName, !imageName.isEmpty {
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDir.appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: path.path) {
                return path
            }
        }
        if let originalPath = document.originalPath, !originalPath.isEmpty {
            let path = URL(fileURLWithPath: originalPath)
            if FileManager.default.fileExists(atPath: path.path) {
                return path
            }
        }
        // Ensure image data exists on disk if only in memory
        if let image = savedImage {
            let filename = document.imageName ?? (UUID().uuidString + ".jpg")
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDir.appendingPathComponent(filename)
            if let data = image.jpegData(compressionQuality: 0.9) {
                try? data.write(to: path)
                return path
            }
        }
        return nil
    }
    
    private var displayPath: String {
        if let path = fileURL?.path {
            return path
        }
        return document.originalPath ?? (document.imageName ?? "N/A")
    }
    
    var body: some View {
        ZStack {
            // MARK: - Black Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Bar (Back + Name + Heart)
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
                        toggleFavorite()
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
                .padding(.bottom, 12)
                .background(Color.black.ignoresSafeArea(edges: .top))
                
                // MARK: - Full Screen Image
                if let image = savedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Image not found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // MARK: - Bottom: Overview Button + Swipe Hint
                ZStack(alignment: .top) {
                    // White card background
                    VStack {
                        Spacer().frame(height: 24)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.compact.up")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Swipe up to see details")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.primary)
                            .padding(.top, 30)
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(32, corners: [.topLeft, .topRight])
                    }
                    
                    // Overview pill button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showOverview = true
                        }
                    } label: {
                        Text("Overview")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color("btn_gradiant_color_1").opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .offset(y: 4)
                }
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
        .onAppear {
            checkFavoriteState()
        }
        .confirmationDialog("Open Image", isPresented: $showOpenPathDialog, titleVisibility: .visible) {
            Button("Open in Photos (Gallery)") {
                openInGallery()
            }
            Button("Open in Files (File Manager)") {
                openInFileManager()
            }
            Button("Save to Files / Share...") {
                showShareSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Open image in Gallery or File Manager, or export it using the system share sheet.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = fileURL {
                ShareSheet(activityItems: [url])
            } else if let image = savedImage {
                ShareSheet(activityItems: [image])
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Favorite Logic
    private func checkFavoriteState() {
        guard let idString = document.id?.uuidString else { return }
        let favoriteIDs = UserDefaults.standard.stringArray(forKey: "FavoriteDocumentIDs") ?? []
        isFavorited = favoriteIDs.contains(idString)
    }
    
    private func toggleFavorite() {
        guard let idString = document.id?.uuidString else { return }
        var favoriteIDs = UserDefaults.standard.stringArray(forKey: "FavoriteDocumentIDs") ?? []
        
        withAnimation(.spring(response: 0.3)) {
            if isFavorited {
                favoriteIDs.removeAll { $0 == idString }
                isFavorited = false
            } else {
                favoriteIDs.append(idString)
                isFavorited = true
            }
        }
        
        UserDefaults.standard.set(favoriteIDs, forKey: "FavoriteDocumentIDs")
        NotificationCenter.default.post(name: NSNotification.Name("FavoritesChanged"), object: nil)
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
                                    Text(displayPath)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                // Open path button
                                Button {
                                    showOpenPathDialog = true
                                } label: {
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
                                .buttonStyle(.plain)
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
    
    // MARK: - Open in Gallery & File Manager
    private func openInGallery() {
        guard let image = savedImage else {
            alertMessage = "Unable to load image."
            showAlert = true
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    saveAndOpenPhotos(image: image)
                } else {
                    DispatchQueue.main.async {
                        alertMessage = "Photo library access is needed to save and open in Gallery."
                        showAlert = true
                    }
                }
            }
        case .authorized, .limited:
            saveAndOpenPhotos(image: image)
        case .denied, .restricted:
            alertMessage = "Photo Library access is denied. Please allow Photos access in Settings."
            showAlert = true
        @unknown default:
            break
        }
    }
    
    private func saveAndOpenPhotos(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    if let photosURL = URL(string: "photos-redirect://") {
                        UIApplication.shared.open(photosURL, options: [:]) { opened in
                            if !opened {
                                alertMessage = "Image saved to Photos! Open the Photos app to view."
                                showAlert = true
                            }
                        }
                    } else {
                        alertMessage = "Image saved to Photos gallery."
                        showAlert = true
                    }
                } else {
                    alertMessage = error?.localizedDescription ?? "Failed to save image to Photos."
                    showAlert = true
                }
            }
        }
    }
    
    private func openInFileManager() {
        guard let _ = fileURL else {
            alertMessage = "Image file could not be found on disk."
            showAlert = true
            return
        }
        
        if let filesURL = URL(string: "shareddocuments://") {
            UIApplication.shared.open(filesURL, options: [:]) { opened in
                if !opened {
                    DispatchQueue.main.async {
                        showShareSheet = true
                    }
                }
            }
        } else {
            showShareSheet = true
        }
    }
}

// MARK: - Share Sheet UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
