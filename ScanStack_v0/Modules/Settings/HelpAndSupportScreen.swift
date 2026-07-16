import SwiftUI

struct HelpAndSupportScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("AccentColor") // Global light gray background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - Top Nav
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
                    
                    Text("Help & Support")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible placeholder for centering
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Contact Support Card
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "00A8F0"))
                            
                            Text("Need Help?")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("Our support team is here to help you with any issues or questions you might have.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button {
                                // Dummy action
                            } label: {
                                Text("Contact Us")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 40)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "00A8F0"), Color(hex: "7E3AF2")],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(24)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(28)
                        .padding(.horizontal, 20)
                        
                        // MARK: - FAQ Section
                        Text("Frequently Asked Questions")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                        
                        VStack(spacing: 16) {
                            FAQRow(question: "How do I reset my password?", answer: "You can reset your password from the login screen by tapping on 'Forgot Password'.")
                            FAQRow(question: "How does the AI Scanner work?", answer: "ScanStack uses advanced CoreML models and Vision OCR to automatically categorize your documents and extract text from images.")
                            FAQRow(question: "Is my data secure?", answer: "Yes, all your scans are stored locally on your device in Core Data unless you manually back them up.")
                            FAQRow(question: "How do I cancel my Pro subscription?", answer: "You can manage your subscription settings directly through your Apple ID in the App Store.")
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
}

#Preview {
    HelpAndSupportScreen()
}
