import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedDocument: ScannedDocument?
    @State private var showSettings = false
    
    // Using AppStorage for the quick logout trick (as it was in original)
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text("Hello, ")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text(viewModel.displayName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text(".")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("Your stacks are organized and digitized.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Quick Stats Grid
                    HStack(spacing: 16) {
                        StatCardView(
                            title: "Total Scans",
                            value: "\(viewModel.totalScans)",
                            icon: "photo.stack",
                            colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")]
                        )
                        
                        StatCardView(
                            title: "Categories",
                            value: "\(viewModel.totalStacks)",
                            icon: "folder.fill",
                            colors: [Color.purple, Color.blue]
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // MARK: - Recent Activity
                    if viewModel.recentScans.isEmpty {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No scans yet!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Head over to the Activity tab to scan your first image.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Activity")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.recentScans, id: \.id) { doc in
                                        Button {
                                            selectedDocument = doc
                                        } label: {
                                            RecentScanCard(document: doc)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // MARK: - Bottom Padding for Tab Bar
                    Spacer().frame(height: 120)
                }
            }
        }
        .onAppear {
            viewModel.fetchDashboardData()
        }
        .fullScreenCover(item: $selectedDocument) { doc in
            ImagePreview(document: doc)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsScreen()
        }
    }
}

// MARK: - Helper Views

struct StatCardView: View {
    var title: String
    var value: String
    var icon: String
    var colors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(colors[0].opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colors[0])
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct RecentScanCard: View {
    let document: ScannedDocument
    
    private var thumbnail: UIImage? {
        guard let imageName = document.imageName else { return nil }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName)
        return UIImage(contentsOfFile: path.path)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 140, height: 140)
                .overlay(
                    Group {
                        if let image = thumbnail {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                )
                .clipped()
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            Text(document.stackName ?? "Uncategorized")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let date = document.dateCreated {
                Text(date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    HomeScreen()
}
