//
//  Registeration.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 19/05/2026.
//

import SwiftUI
import GoogleSignIn

struct Registeration: View {
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    //google signin authentication
    func performGoogleSignIn() {
        // Get the root view controller to present the Google Sign-in web flow overlay
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Error: Unable to find root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            
            guard let result = signInResult else { return }
            
            // Successful Authentication
            let user = result.user
            let email = user.profile?.email
            let name = user.profile?.name
            
            print("Signed in user: \(name ?? "Unknown") (\(email ?? "No Email"))")
            
            // Save user session and navigate to HomeScreen
            withAnimation {
                self.isLoggedIn = true
            }
        }
    }

    
    @State private var animateLogo = false
    @State private var animateLogoBack = false
    
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var navigateToSecurity = false

    // Set minimum date boundary to Jan 1, 1960 (from your UIKit code)
    private var minDate: Date {
        var components = DateComponents()
        components.year = 1960
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    // Check if age is valid (At least 16 years old)
    private var isAgeValid: Bool {
        let ageComponents = Calendar.current.dateComponents([.year], from: viewModel.selectedDate, to: Date())
        let age = ageComponents.year ?? 0
        return age >= 16 && !viewModel.dateOfBirth.isEmpty
    }

    
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
                        .fill(Color("LogoBack")) // Ensure this color exists in your assets!
                        .frame(width: 60, height: 60)
                        .cornerRadius(18)
                        .rotationEffect(.degrees(animateLogoBack ? -8 : 0))
                        .offset(x: animateLogoBack ? -4 : 0, y: animateLogoBack ? -4 : 0)
                    
                    Image("ScanStackLogo") // Ensure this image exists in your assets!
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
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
                Text("Welcome! Let’s get you started.")
                    .foregroundStyle(Color(hex: "2C2F31"))
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                    .frame(width: 320, height: 72)
                    .multilineTextAlignment(.center)
                Text("Tell us a bit about yourself to personalize your ScanStack.")
                    .foregroundStyle(Color(hex: "595C5E"))
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .frame(width: 320, height: 72)
                    .multilineTextAlignment(.center)
                    .padding(.top, -16)
                
                VStack{
                    HStack{
                        TextField("Full Name", text: $viewModel.fullName)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(.label))
                            .autocorrectionDisabled()
                            .padding(.horizontal, 24)
                            .frame(width: 344, height: 54)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                    }
                    
                    HStack{
                        TextField("Email Address", text: $viewModel.email)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(.label))
                            .autocorrectionDisabled()
                            .padding(.horizontal, 24)
                            .frame(width: 344, height: 54)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.top, 6)
                    }
                    
                    HStack {
                        HStack(spacing: 14) {
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: "006289"))
                            
                            // Changed to Text view so the keyboard doesn't open manually
                            Text(viewModel.dateOfBirth.isEmpty ? "Date of Birth (DD/MM/YYYY)" : viewModel.dateOfBirth)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(viewModel.dateOfBirth.isEmpty ? Color(.placeholderText) : Color(.label))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .frame(width: 344, height: 54)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .overlay(
                            // Transparent DatePicker container enforcing your strict UIKit rules
                            DatePicker(
                                "",
                                selection: $viewModel.selectedDate,
                                in: minDate...Date(), // Min: 1960, Max: Today
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .scaleEffect(x: 10, y: 1, anchor: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .colorMultiply(.clear) // Completely invisible, fully tappable
                            .onChange(of: viewModel.selectedDate) { newDate in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "dd/MM/yyyy"
                                viewModel.dateOfBirth = formatter.string(from: newDate)
                            }
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    // Turns red if they pick a date but are under 16 years old
                                    (!viewModel.dateOfBirth.isEmpty && !isAgeValid) ? Color.red : Color(hex: "ABADAF").opacity(0.30),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.top, 6)


                    
                    if let errorMsg = viewModel.errorMessage {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }

                    Button(action: {
                        if viewModel.validateRegistrationDetails() {
                            navigateToSecurity = true
                        }
                    }) {
                        HStack(alignment: .center) {
                            Text("Create Account")
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundStyle(.white)
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
                        .padding(.top, 10)
                        .shadow(radius: 6)
                        .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
                    }
                    .frame(width: 344)
                    
                    NavigationLink(destination: Security(viewModel: viewModel), isActive: $navigateToSecurity) {
                        EmptyView()
                    }
                    
                    HStack(spacing: 16) { // Controls space between lines and text
                        
                        // 1. Left Divider Line
                        Divider()
                            .frame(width: 138, height: 1) // Enforces a crisp 1-pixel baseline profile
                            .overlay(Color(hex: "000000").opacity(0.2)) // Subtle contrasting tone matching the image
                        
                        // 2. Central Text Asset
                        Text("OR")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "000000").opacity(0.3)) // Muted text styling matching the asset backdrop
                            .tracking(1.5) // Adds precise kerning/letter-spacing for clean UI feel
                        
                        // 3. Right Divider Line
                        Divider()
                            .frame(width: 138, height: 1)
                            .overlay(Color(hex: "000000").opacity(0.2))
                    }
                    .padding(.horizontal, 24) // Keeps the layout safely padded away from device screen margins
                    .padding(.top, 20)
                    
                    Button(action: {
                        performGoogleSignIn()
                    }) {
                        HStack(spacing: 14) {
                            // Google Brand Image Asset
                            Image("Google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                            
                            // Button Content Title Label (Static View instead of TextField input)
                            Text("Sign in with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black) // Matches your layout color rules
                        }
                        .padding(.horizontal, 24)
                        .frame(width: 344, height: 60) // Retains your exact custom dimensions
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.top, 16)
                }
                
            }
            .padding(.top, 16)
            
        }
        .navigationBarBackButtonHidden(true)
        
        
        
    }
}


#Preview {
    Registeration()
}
