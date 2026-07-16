import SwiftUI
import LocalAuthentication

struct SecuritySettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lockManager = AppLockManager.shared
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Security & FaceID")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible placeholder
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 20, weight: .semibold))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // MARK: - FaceID Toggle
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Lock")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Require Face ID / Passcode to open app")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { lockManager.isAppLockEnabled },
                            set: { newValue in
                                if newValue {
                                    // Try to enable it by checking if it's available first
                                    let context = LAContext()
                                    var error: NSError?
                                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                                        lockManager.isAppLockEnabled = true
                                    } else {
                                        errorMessage = "Biometrics or passcode are not set up on this device."
                                        showingError = true
                                    }
                                } else {
                                    // Turning it off is always allowed
                                    lockManager.isAppLockEnabled = false
                                }
                            }
                        ))
                        .labelsHidden()
                        .tint(Color("btn_gradiant_color_0"))
                    }
                    .padding(20)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Cannot Enable App Lock"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    SecuritySettingsScreen()
}
