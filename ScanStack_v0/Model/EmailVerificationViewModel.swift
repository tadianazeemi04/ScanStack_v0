import Foundation
import FirebaseAuth
import Combine

class EmailVerificationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isVerified = false
    
    func checkVerificationStatus() {
        guard let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        user.reload { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if user.isEmailVerified {
                    self?.isVerified = true
                } else {
                    self?.errorMessage = "Email not verified yet. Please check your inbox and click the link."
                }
            }
        }
    }
    
    func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Verification email sent! Check your inbox."
                }
            }
        }
    }
}
