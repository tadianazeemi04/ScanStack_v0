//
//  Security.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 02/07/2026.
//

import SwiftUI

// MARK: - Password Strength Helper

private enum PasswordStrength {
    case empty, weak, fair, strong, veryStrong

    var label: String {
        switch self {
        case .empty:      return "Waiting..."
        case .weak:       return "WEAK PASSWORD"
        case .fair:       return "FAIR PASSWORD"
        case .strong:     return "STRONG PASSWORD"
        case .veryStrong: return "VERY STRONG"
        }
    }

    var percentage: Double {
        switch self {
        case .empty:      return 0.0
        case .weak:       return 0.25
        case .fair:       return 0.50
        case .strong:     return 0.65
        case .veryStrong: return 1.0
        }
    }

    var percentageLabel: String {
        switch self {
        case .empty:      return "0% secure"
        case .weak:       return "25% secure"
        case .fair:       return "50% secure"
        case .strong:     return "65% secure"
        case .veryStrong: return "100% secure"
        }
    }

    var color: Color {
        switch self {
        case .empty:      return Color.gray
        case .weak:       return Color(hex: "FF4D4D")
        case .fair:       return Color(hex: "FFA500")
        case .strong:     return Color(hex: "7B2FBE")
        case .veryStrong: return Color(hex: "34C759")
        }
    }
}

private func evaluateStrength(_ password: String) -> PasswordStrength {
    guard !password.isEmpty else { return .empty }
    var score = 0
    if password.count >= 8                                           { score += 1 }
    if password.range(of: "[0-9]",  options: .regularExpression) != nil { score += 1 }
    if password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]",
                      options: .regularExpression) != nil            { score += 1 }
    if password.count >= 12                                          { score += 1 }

    switch score {
    case 0:       return .weak
    case 1:       return .weak
    case 2:       return .fair
    case 3:       return .strong
    default:      return .veryStrong
    }
}

// MARK: - Checklist Row

private struct ChecklistRow: View {
    let text: String
    let isChecked: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(isChecked ? Color(hex: "34C759") : Color(hex: "ABADAF").opacity(0.5),
                            lineWidth: 1.5)
                    .frame(width: 22, height: 22)

                if isChecked {
                    Circle()
                        .fill(Color(hex: "34C759"))
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isChecked)

            Text(text)
                .font(.system(size: 15, weight: isChecked ? .semibold : .regular))
                .foregroundColor(isChecked ? Color(hex: "2C2F31") : Color(hex: "ABADAF"))
                .animation(.easeInOut(duration: 0.25), value: isChecked)
        }
    }
}

// MARK: - Animated Strength Bar

private struct StrengthBar: View {
    let strength: PasswordStrength

    var gradientColors: [Color] {
        switch strength {
        case .empty:      return [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]
        case .weak:       return [Color(hex: "FF4D4D"), Color(hex: "FF8080")]
        case .fair:       return [Color(hex: "FFA500"), Color(hex: "FFD080")]
        case .strong:     return [Color(hex: "006289"), Color(hex: "7B2FBE")]
        case .veryStrong: return [Color(hex: "34C759"), Color(hex: "00CFAA")]
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color(hex: "F4F6FB"))
                    .frame(height: 5)

                // Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * strength.percentage, height: 5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: strength.percentage)
            }
        }
        .frame(height: 5)
    }
}

// MARK: - Password Field

private struct PasswordInputField: View {
    let label: String
    let icon: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @FocusState private var isTextFieldFocused: Bool

    // 1. Tracks the rotation degree of the background gradient wheel
    @State private var rotationAngle: Double = 0.0

    // Static Asset Catalog Gradient for the Text Label
    private var labelGradient: LinearGradient {
        LinearGradient(
            colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(isTextFieldFocused ? labelGradient : LinearGradient(colors: [Color(hex: "757779")], startPoint: .top, endPoint: .bottom))
                .tracking(1.2)
                .padding(.leading, 4)

            HStack(spacing: 14) {
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "6B6E70"))
                }

                Group {
                    if isVisible {
                        TextField("", text: $text)
                            .tint(Color(hex: "757779"))
                            .focused($isTextFieldFocused)
                    } else {
                        SecureField("", text: $text)
                            .tint(Color(hex: "757779"))
                            .focused($isTextFieldFocused)
                    }
                }
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(hex: "2C2F31"))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isVisible.toggle() } }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(hex: "ABADAF"))
                }
            }
            .padding(.horizontal, 16)
            .frame(width: 300, height: 54)
            .background(
                Capsule()
                    .fill(Color.white).opacity(0.6)
            )
            .overlay(
                // 2. The outer border layer
                Group {
                    if isTextFieldFocused {
                        // The Spinning Gradient Wheel
                        Rectangle()
                            .fill(
                                AngularGradient(
                                    colors: [
                                        Color("btn_gradiant_color_0"),
                                        Color("btn_gradiant_color_1"),
                                        Color("btn_gradiant_color_0") // Clean seam loop
                                    ],
                                    center: .center
                                )
                            )
                            // Make it large enough to fully cover the width of the capsule during rotation
                            .frame(width: 360, height: 360)
                            .rotationEffect(.degrees(rotationAngle))
                            // 3. Mask it so ONLY the 2px Capsule stroke is visible
                            .mask(
                                Capsule()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 300, height: 54)
                            )
                            .allowsHitTesting(false)
                    } else {
                        // Default static fallback border when not active
                        Capsule()
                            .stroke(Color(hex: "ABADAF").opacity(0.30), lineWidth: 1)
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            // 4. Drive the animation loop purely based on focus change
            .onChange(of: isTextFieldFocused) { _, isFocused in
                if isFocused {
                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                        rotationAngle = 360.0
                    }
                } else {
                    rotationAngle = 0.0
                }
            }
        }
    }
}


/*private struct PasswordInputField: View {
    let label: String
    let icon: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "757779"))
                .tracking(1.2)
                .padding(.leading, 4)

            HStack(spacing: 14) {
                // Lock icon badge
                ZStack {
//                    Circle()
//                        .fill(Color(hex: "F5F5F7"))
//                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "6B6E70"))
                }

                // Password / text field
                Group {
                    if isVisible {
                        TextField("", text: $text)
                    } else {
                        SecureField("", text: $text)
                    }
                }
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(hex: "2C2F31"))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                // Eye toggle
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isVisible.toggle() } }) {
                    Image(systemName: isVisible ? "eye" : "eye")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(hex: "ABADAF"))
                }
            }
            .padding(.horizontal, 16)
            .frame(width: 336, height: 54)
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
    }
}*/

// MARK: - Main Security View

struct Security: View {

    // MARK: State
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var navigateToVerification = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmVisible: Bool = false

    @State private var animateLogo = false
    @State private var animateLogoBack = false

    // Button press animation
    @State private var isButtonPressed = false

    // MARK: Computed
    private var strength: PasswordStrength { evaluateStrength(viewModel.password) }

    private var hasMinLength:  Bool { viewModel.password.count >= 8 }
    private var hasNumber:     Bool { viewModel.password.range(of: "[0-9]", options: .regularExpression) != nil }
    private var hasSpecial:    Bool {
        viewModel.password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]",
                       options: .regularExpression) != nil
    }

    // MARK: Body
    var body: some View {
        ZStack(alignment: .top) {

            // ── Background ──────────────────────────────────────
            Color("AccentColor")
                .ignoresSafeArea()

            Ellipse()
                .fill(Color.btnGradiantColor0).opacity(1)
                .blur(radius: 130)
                .frame(width: 316, height: 316)
                .offset(x: 90, y: -100)

            Ellipse()
                .fill(Color.btnGradiantColor1).opacity(1)
                .blur(radius: 180)
                .frame(width: 316, height: 316)
                .offset(x: 0, y: 550)

            // ── Content ─────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {

                    HStack {
                        // ── Logo ──
                        ZStack(alignment: .center) {
                            Rectangle()
                                .fill(Color("btn_gradiant_color_0"))
                                .frame(width: 50, height: 50)
                                .cornerRadius(18)
                                .rotationEffect(.degrees(animateLogoBack ? 8 : 0))
                                .offset(x: animateLogoBack ? 4 : 0, y: animateLogoBack ? 4 : 0)
                            
                            Rectangle()
                                .fill(Color("LogoBack"))
                                .frame(width: 50, height: 50)
                                .cornerRadius(18)
                                .rotationEffect(.degrees(animateLogoBack ? -8 : 0))
                                .offset(x: animateLogoBack ? -4 : 0, y: animateLogoBack ? -4 : 0)
                            
                            Image("ScanStackLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                                animateLogoBack = true
                            }
                        }
                        
                        // ── Brand name ──
                        Text("ScanStack")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "006289"), Color("btn_gradiant_color_1")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .padding(.leading, 8)
                    }
                    .padding(.bottom, 10)
                    
                    // ── Glassmorphism card: Headline → Back button ──
                    VStack(alignment: .center, spacing: 16) {

                        // Headline
                        Text("Secure your\naccount.")
                            .foregroundStyle(Color(hex: "2C2F31"))
                            .font(.system(size: 28, weight: .heavy))
                            .multilineTextAlignment(.center)
                            .padding(.top, -4)

                        // Subtitle
                        Text("Choose a strong password to keep\nyour stacks private.")
                            .foregroundStyle(Color(hex: "595C5E"))
                            .font(.system(size: 16, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.top, -6)

                        // ── Form ──
                        VStack(alignment: .leading, spacing: 16) {

                            // Password field
                            PasswordInputField(
                                label: "PASSWORD",
                                icon: "lock",
                                text: $viewModel.password,
                                isVisible: $isPasswordVisible
                            )

                            // Strength bar — always visible from the start
                            VStack(alignment: .leading, spacing: 4) {
                                StrengthBar(strength: strength)
                                    .frame(maxWidth: .infinity)

                                HStack {
                                    Text(strength == .empty ? "" : strength.label)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(strength.color)
                                        .tracking(1.0)
                                        .animation(.easeInOut(duration: 0.3), value: strength.label)

                                    Spacer()

                                    Text(strength == .empty ? "" : strength.percentageLabel)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(Color(hex: "ABADAF"))
                                        .animation(.easeInOut(duration: 0.3), value: strength.percentageLabel)
                                }
                                .frame(maxWidth: 300)
                            }

                            // Confirm password field
                            PasswordInputField(
                                label: "CONFIRM PASSWORD",
                                icon: "lock.rotation",
                                text: $viewModel.confirmPassword,
                                isVisible: $isConfirmVisible
                            )

                            // ── Safety Checklist ──
                            VStack(alignment: .leading, spacing: 0) {
                                Text("SAFETY CHECKLIST")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "757779"))
                                    .tracking(1.2)
                                    .padding(.bottom, 12)

                                VStack(alignment: .leading, spacing: 14) {
                                    ChecklistRow(text: "At least 8 characters",    isChecked: hasMinLength)
                                    ChecklistRow(text: "Contains a number",         isChecked: hasNumber)
                                    ChecklistRow(text: "Special character (!@#$)",  isChecked: hasSpecial)
                                }
                            }
                            .frame(maxWidth: 300, alignment: .leading)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            )

                        }
                        .padding(.top, 4)

                        // ── Set Password Button ──
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                isButtonPressed = true
                            }
                            viewModel.registerUser()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                    isButtonPressed = false
                                }
                            }
                        }) {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Set Password")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.white)

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(x: isButtonPressed ? 4 : 0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isButtonPressed)
                                }
                            }
                            .frame(maxWidth: 300, minHeight: 68, alignment: .center)
                            .background(
                                LinearGradient(
                                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(1000)
                            .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                            .shadow(radius: 6)
                            .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
                            .padding(.top, 6)
                        }
                        .disabled(viewModel.isLoading)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(Color(hex: "FF4D4D"))
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                        }

                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        // Glassmorphism: frosted glass + white tint layer
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white.opacity(0.25))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                    .padding(.horizontal, 46)
                    .padding(.top, 10)
                    

                    
                    NavigationLink(destination: EmailVerificationView(), isActive: $navigateToVerification) {
                        EmptyView()
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.registrationSuccess) { _, success in
            if success {
                navigateToVerification = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        Security(viewModel: RegistrationViewModel())
    }
}
