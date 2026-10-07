//
//  Registeration.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 19/05/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

struct Registeration: View {
    
    enum RegField { case name, email }
    @FocusState private var focusedField: RegField?
    @State private var nameRotation: Double = 0.0
    @State private var emailRotation: Double = 0.0
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var isGoogleLoading = false
    
    //google signin authentication
    func performGoogleSignIn() {
        // Get the root view controller to present the Google Sign-in web flow overlay
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Error: Unable to find root view controller")
            return
        }
        
        withAnimation {
            isGoogleLoading = true
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    withAnimation {
                        self.isGoogleLoading = false
                    }
                }
                return
            }
            
            guard let result = signInResult else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.isGoogleLoading = false
                    }
                }
                return
            }
            let user = result.user
            
            // 1. Get Google tokens
            guard let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.isGoogleLoading = false
                    }
                }
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // 2. Sign in to Firebase using the Google credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-in error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isGoogleLoading = false
                        }
                    }
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isGoogleLoading = false
                        }
                    }
                    return
                }
                
                // 3. Save to Firestore Database
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "uid": firebaseUser.uid,
                    "fullName": user.profile?.name ?? "Unknown",
                    "email": user.profile?.email ?? "No Email",
                    "dateOfBirth": "", // Left empty as per user request
                    "createdAt": Timestamp(date: Date())
                ]
                
                db.collection("users").document(firebaseUser.uid).setData(userData, merge: true) { error in
                    if let error = error {
                        print("Failed to save Google user to database: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            withAnimation {
                                self.isGoogleLoading = false
                            }
                        }
                    } else {
                        // 4. Finally, navigate to Home Screen
                        DispatchQueue.main.async {
                            withAnimation {
                                self.isLoggedIn = true
                            }
                        }
                    }
                }
            }
        }
    }

    
    @State private var animateLogo = false
    @State private var animateLogoBack = false
    
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var navigateToSecurity = false
    @State private var navigateToLogin = false

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
                            .focused($focusedField, equals: .name)
                            .tint(Color(hex: "757779"))
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
                                Group {
                                    if focusedField == .name {
                                        Rectangle()
                                            .fill(AngularGradient(colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1"), Color("btn_gradiant_color_0")], center: .center))
                                            .frame(width: 400, height: 400)
                                            .rotationEffect(.degrees(nameRotation))
                                            .mask(Capsule().stroke(lineWidth: 2).frame(width: 344, height: 54))
                                            .allowsHitTesting(false)
                                    } else {
                                        Capsule().stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                                    }
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .onChange(of: focusedField) { _, field in
                                if field == .name {
                                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                                        nameRotation = 360.0
                                    }
                                } else {
                                    nameRotation = 0.0
                                }
                            }
                        
                    }
                    
                    HStack{
                        TextField("Email Address", text: $viewModel.email)
                            .focused($focusedField, equals: .email)
                            .tint(Color(hex: "757779"))
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
                                Group {
                                    if focusedField == .email {
                                        Rectangle()
                                            .fill(AngularGradient(colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1"), Color("btn_gradiant_color_0")], center: .center))
                                            .frame(width: 400, height: 400)
                                            .rotationEffect(.degrees(emailRotation))
                                            .mask(Capsule().stroke(lineWidth: 2).frame(width: 344, height: 54))
                                            .allowsHitTesting(false)
                                    } else {
                                        Capsule().stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                                    }
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .onChange(of: focusedField) { _, field in
                                if field == .email {
                                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                                        emailRotation = 360.0
                                    }
                                } else {
                                    emailRotation = 0.0
                                }
                            }
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
                            Text("Signup with Google")
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
                    
                    // ── Login Link ──
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "595C5E"))
                        
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Login here")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "006289"))
                        }
                    }
                    .padding(.top, 14)
                    
                    NavigationLink(destination: Login(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                }
                
            }
            .padding(.top, 16)
            
            // ── Google Sign In Loading Overlay ──
            if isGoogleLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.6)
                        
                        Text("Signing in with Google...")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Please wait a moment")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isGoogleLoading)
        .navigationBarBackButtonHidden(true)
        
        
        
    }
}


#Preview {
    Registeration()
}
