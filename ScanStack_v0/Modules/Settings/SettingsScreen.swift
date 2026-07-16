import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSubscription = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AccentColor") // Global light gray background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Top Nav (Back Button)
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.uturn.backward")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 16, weight: .bold))
                                    )
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Profile Header
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                if let url = viewModel.profilePhotoURL {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        case .failure:
                                            Image(systemName: "person.crop.square.fill")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.gray)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.crop.square.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                }
                                
                                // Edit Icon Badge
                                Circle()
                                    .fill(Color("btn_gradiant_color_0")) // Teal color
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .bold))
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 3)
                                    )
                                    .offset(x: 10, y: 10)
                            }
                            
                            VStack(spacing: 4) {
                                Text(viewModel.displayName)
                                    .font(.system(size: 26, weight: .heavy))
                                    .foregroundColor(.primary)
                                    .padding(.top, 12)
                                
                                Text(viewModel.email)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, -50)
                        
                        // MARK: - Premium Banner
                        ZStack(alignment: .topTrailing) {
                            // Background Gradient
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                            
                            // Faint Star watermark
                            Image(systemName: "star.fill")
                                .font(.system(size: 120))
                                .foregroundColor(.white.opacity(0.1))
                                .offset(x: 40, y: -20)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                // Premium Tag
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                    Text("PREMIUM MEMBER")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(20)
                                
                                Text("ScanStack Pro")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Unlimited stacks, AI OCR\nextraction, no Ads and\npremium features")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.bottom, 8)
                                
                                Button {
                                    showSubscription = true
                                } label: {
                                    Text("Manage Subscription")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color("btn_gradiant_color_0"))
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(24)
                        }
                        .frame(height: 220)
                        .cornerRadius(28)
                        .padding(.horizontal, 20)
                        
                        // MARK: - Storage Insights
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("STORAGE INSIGHTS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                    .kerning(1.2)
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(viewModel.formattedTotalUsed) of 128GB used")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "cloud")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color("btn_gradiant_color_0"))
                            }
                            
                            // Fake progress bar using segments based on actual core data categories!
                            GeometryReader { geo in
                                HStack(spacing: 0) {
                                    if viewModel.storageInsights.isEmpty {
                                        Capsule()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 10)
                                    } else {
                                        // To make it look like the figma, we just hardcode the visual proportions of the insights for now if total is very small
                                        // since 128GB is huge and MBs wouldn't even show up.
                                        let baseWidth = geo.size.width * 0.4
                                        ForEach(Array(viewModel.storageInsights.enumerated()), id: \.element.id) { index, insight in
                                            Rectangle()
                                                .fill(Color(hex: insight.colorHex))
                                                .frame(width: baseWidth * (index == 0 ? 0.6 : 0.4))
                                        }
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .clipShape(Capsule())
                            }
                            .frame(height: 10)
                            
                            // Labels
                            HStack(spacing: 40) {
                                ForEach(viewModel.storageInsights) { insight in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(Color(hex: insight.colorHex))
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 4)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(insight.category.uppercased())
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.gray)
                                            Text(insight.formattedSize)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(28)
                        .padding(.horizontal, 20)
                        
                        // MARK: - System Settings Menu
                        VStack(alignment: .leading, spacing: 0) {
                            Text("SYSTEM SETTINGS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .kerning(1.2)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: SecuritySettingsScreen()) {
                                    SettingsRow(icon: "faceid", title: "Security & FaceID")
                                }
                                Divider().padding(.leading, 64)
                                Button {
                                    showSubscription = true
                                } label: {
                                    SettingsRow(icon: "crown", title: "Pricing Plans")
                                }
                                Divider().padding(.leading, 64)
                                NavigationLink(destination: HelpAndSupportScreen()) {
                                    SettingsRow(icon: "questionmark.circle", title: "Help & Support")
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(28)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Sign Out
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.vertical, 10)
                        }
                        
                        Spacer().frame(height: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showSubscription) {
                SubscriptionScreen()
            }
            .alert("Confirm Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    viewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to log out of your account?")
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                )
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    SettingsScreen()
}
