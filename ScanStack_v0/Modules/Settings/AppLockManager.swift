import SwiftUI
import LocalAuthentication
import Combine

@MainActor
class AppLockManager: ObservableObject {
    static let shared = AppLockManager()
    
    @AppStorage("isAppLockEnabled") var isAppLockEnabled: Bool = false
    @Published var isUnlocked: Bool = false
    
    private init() {
        // If app lock is not enabled, we are always "unlocked"
        self.isUnlocked = !isAppLockEnabled
    }
    
    func requireAuthentication() {
        // Called when the app enters the background to reset the lock state
        if isAppLockEnabled {
            isUnlocked = false
        }
    }
    
    func authenticate() {
        guard isAppLockEnabled, !isUnlocked else { return }
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric auth is available
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock ScanStack to view your private documents."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // User canceled or failed. The screen remains locked.
                        print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            // No biometrics or passcode set up on device.
            print("Biometrics unavailable: \(error?.localizedDescription ?? "Unknown error")")
            // Fallback: we could just unlock it if there's no passcode, but typically you shouldn't let them enable it if it's unavailable.
        }
    }
}
