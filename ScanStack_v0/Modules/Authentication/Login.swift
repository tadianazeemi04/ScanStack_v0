//
//  Login.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 06/07/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

struct Login: View {
    
    enum LoginField { case email, password }
    @FocusState private var focusedField: LoginField?
    @State private var emailRotation: Double = 0.0
    @State private var passwordRotation: Double = 0.0
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToVerification = false
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @Environment(\.presentationMode) var presentationMode
    
    // Google sign-in authentication
    func performGoogleSignIn() {
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
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-in error: \(error.localizedDescription)")
                    return
                }
                
                guard let firebaseUser = authResult?.user else { return }
                
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "uid": firebaseUser.uid,
                    "fullName": user.profile?.name ?? "Unknown",
                    "email": user.profile?.email ?? "No Email",
                    "lastLoginAt": Timestamp(date: Date())
                ]
                
                db.collection("users").document(firebaseUser.uid).setData(userData, merge: true) { error in
                    if let error = error {
                        print("Failed to update Google user: \(error.localizedDescription)")
                    } else {
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
    
    @State private var animateLogoBack = false
    @StateObject private var viewModel = LoginViewModel()
    
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
                Text("Welcome back!\nLog in to continue.")
                    .foregroundStyle(Color(hex: "2C2F31"))
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                    .frame(width: 320, height: 72)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                
                VStack{
                    HStack{
                        TextField("Email Address", text: $viewModel.email)
                            .focused($focusedField, equals: .email)
                            .tint(Color(hex: "757779"))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(.label))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
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
                    }
                    .padding(.top, 16)
                    
                    HStack(spacing: 14) {
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                                    .tint(Color(hex: "757779"))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(.label))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                                    .tint(Color(hex: "757779"))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(.label))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isPasswordVisible.toggle() } }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Color(hex: "ABADAF"))
                        }
                    }
                            .padding(.horizontal, 24)
                            .frame(width: 344, height: 54)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Group {
                                    if focusedField == .password {
                                        Rectangle()
                                            .fill(AngularGradient(colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1"), Color("btn_gradiant_color_0")], center: .center))
                                            .frame(width: 400, height: 400)
                                            .rotationEffect(.degrees(passwordRotation))
                                            .mask(Capsule().stroke(lineWidth: 2).frame(width: 344, height: 54))
                                            .allowsHitTesting(false)
                                    } else {
                                        Capsule().stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                                    }
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .onChange(of: focusedField) { _, field in
                                if field == .password {
                                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                                        passwordRotation = 360.0
                                    }
                                } else {
                                    passwordRotation = 0.0
                                }
                            }
                            .padding(.top, 6)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.resetPassword()
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "006289"))
                        }
                    }
                    .frame(width: 344)
                    .padding(.top, 4)
                    
                    if let successMsg = viewModel.resetPasswordSuccessMessage {
                        Text(successMsg)
                            .foregroundColor(Color(hex: "34C759"))
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }
                    
                    if let errorMsg = viewModel.errorMessage {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }
                    
                    Button(action: {
                        viewModel.loginUser()
                    }) {
                        HStack(alignment: .center) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .font(.system(size: 24, weight: .bold, design: .default))
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
                        .padding(.top, viewModel.errorMessage == nil ? 4 : 8)
                        .shadow(radius: 6)
                        .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
                    }
                    .frame(width: 344)
                    .disabled(viewModel.isLoading)
                    
                    HStack(spacing: 16) {
                        Divider()
                            .frame(width: 138, height: 1)
                            .overlay(Color(hex: "000000").opacity(0.2))
                        
                        Text("OR")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "000000").opacity(0.3))
                            .tracking(1.5)
                        
                        Divider()
                            .frame(width: 138, height: 1)
                            .overlay(Color(hex: "000000").opacity(0.2))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    Button(action: {
                        performGoogleSignIn()
                    }) {
                        HStack(spacing: 14) {
                            Image("Google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                            
                            Text("Login with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black)
                        }
                        .padding(.horizontal, 24)
                        .frame(width: 344, height: 60)
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
                    
                    // ── Sign Up Link ──
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "595C5E"))
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Sign up here")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "006289"))
                        }
                    }
                    .padding(.top, 24)
                    
                    NavigationLink(destination: EmailVerificationView(), isActive: $navigateToVerification) {
                        EmptyView()
                    }
                }
            }
            .padding(.top, 32)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.loginSuccess) { _, success in
            if success {
                if viewModel.isEmailVerified {
                    isLoggedIn = true
                } else {
                    navigateToVerification = true
                }
            }
        }
    }
}

#Preview {
    Login()
}
