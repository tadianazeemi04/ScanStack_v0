import SwiftUI

struct SubscriptionScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("AccentColor") // Global light gray background
                .ignoresSafeArea()
            
            // MARK: - Header
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "00A8F0"), Color(hex: "7E3AF2")],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("ScanStack Pro ✨")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Invisible placeholder for centering
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .bold))
                            .opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(height: 60)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        
                        // MARK: - PRO Card
                        ZStack(alignment: .top) {
                            // Card Body
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Pro")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(Color(hex: "333333"))
                                        Text("For power curators")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .bottom, spacing: 2) {
                                        Text("Rs.750")
                                            .font(.system(size: 32, weight: .black))
                                            .foregroundColor(Color(hex: "006A8A")) // Dark teal
                                        Text("/month")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 6)
                                    }
                                }
                                .padding(.top, 24)
                                
                                // Feature List
                                VStack(alignment: .leading, spacing: 16) {
                                    FeatureRow(text: "Unlimited Intelligent Stacks")
                                    FeatureRow(text: "AI-Powered OCR")
                                    FeatureRow(text: "50GB Secure Cloud Storage")
                                    FeatureRow(text: "Priority Support")
                                }
                                .padding(.vertical, 8)
                                
                                // Upgrade Button
                                Button {
                                    // Action
                                } label: {
                                    Text("UPGRADE TO PRO")
                                        .font(.system(size: 15, weight: .bold))
                                        .kerning(1.2)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "00A8F0"), Color(hex: "7E3AF2")],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: Color(hex: "7E3AF2").opacity(0.3), radius: 10, x: 0, y: 8)
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            }
                            .padding(.horizontal, 24)
                            .background(Color.white)
                            .cornerRadius(32)
                            .shadow(color: Color(hex: "7E3AF2").opacity(0.15), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, 20)
                            .padding(.top, 20) // Give space for the badge
                            
                            // "Most Popular" Badge bridging the top
                            Text("MOST POPULAR")
                                .font(.system(size: 11, weight: .bold))
                                .kerning(1.0)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(hex: "38C2FF")) // Light blue
                                .cornerRadius(20)
                                .offset(y: 8)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Basic Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center) {
                                Text("Basic")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "333333"))
                                
                                Text("CURRENT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 2) {
                                    Text("Rs.0")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(Color(hex: "333333"))
                                    Text("/month")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 4)
                                }
                            }
                            
                            Text("Standard OCR • 100 Scans per\nDay with ads")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "006A8A")) // Dark teal
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "333333"))
        }
    }
}

#Preview {
    SubscriptionScreen()
}
