import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @StateObject private var viewModel = EmailVerificationViewModel()
    @State private var animateLogoBack = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        ZStack(alignment: .top){
            // background color
            Color("AccentColor")
                .ignoresSafeArea()
            
            Ellipse()
                .fill(Color.btnGradiantColor0).opacity(0.8)
                .blur(radius: 130)
                .frame(width: 316, height: 316)
                .offset(x: 90, y: -100)
            
            Ellipse()
                .fill(Color.btnGradiantColor1).opacity(0.8)
                .blur(radius: 180)
                .frame(width: 316, height: 316)
                .offset(x: 0, y: 550)
            
            VStack(alignment: .center, spacing: 10){
                
                ZStack(alignment: .center) {
                    Rectangle()
                        .fill(Color("btn_gradiant_color_0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(18)
                        .rotationEffect(.degrees(animateLogoBack ? 8 : 0))
                        .offset(x: animateLogoBack ? 4 : 0, y: animateLogoBack ? 4 : 0)
                    
                    Rectangle()
                        .fill(Color("LogoBack")) 
                        .frame(width: 60, height: 60)
                        .cornerRadius(18)
                        .rotationEffect(.degrees(animateLogoBack ? -8 : 0))
                        .offset(x: animateLogoBack ? -4 : 0, y: animateLogoBack ? -4 : 0)
                    
                    Image("ScanStackLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        animateLogoBack = true
                    }
                }
                
                Text("ScanStack")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "006289"), Color("btn_gradiant_color_1")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                
                Text("Check Your Inbox")
                    .foregroundStyle(Color(hex: "2C2F31"))
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                    .frame(width: 320, height: 40)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                
                Text("We've sent a verification email to your address. Please click the link to continue.")
                    .foregroundStyle(Color(hex: "595C5E"))
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 320)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                
                VStack {
                    if let errorMsg = viewModel.errorMessage {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                    }
                    
                    if let successMsg = viewModel.successMessage {
                        Text(successMsg)
                            .foregroundColor(Color(hex: "34C759"))
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                    }
                    
                    Button(action: {
                        viewModel.checkVerificationStatus()
                    }) {
                        HStack(alignment: .center) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("I've Verified My Email")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 338, height: 68, alignment: .center)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(1000)
                        .padding(.top, 24)
                        .shadow(radius: 6)
                        .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
                    }
                    .frame(width: 344)
                    .disabled(viewModel.isLoading)
                    
                    Button(action: {
                        viewModel.resendVerificationEmail()
                    }) {
                        Text("Resend Email")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "006289"))
                            .padding(.top, 16)
                    }
                }
            }
            .padding(.top, 64)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isVerified) { _, success in
            if success {
                withAnimation {
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    EmailVerificationView()
}
