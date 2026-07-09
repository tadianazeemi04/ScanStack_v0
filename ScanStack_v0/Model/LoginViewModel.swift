import Foundation
import FirebaseAuth
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var loginSuccess = false
    @Published var isEmailVerified = false
    @Published var resetPasswordSuccessMessage: String?
    
    func validateLoginDetails() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email Address is required."
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: email) {
            errorMessage = "Please enter a valid email address."
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password is required."
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    func loginUser() {
        guard validateLoginDetails() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: trimmedEmail, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    let errorDesc = error.localizedDescription
                    if errorDesc.contains("malformed") || errorDesc.contains("expired") || errorDesc.contains("invalid login") {
                        self.errorMessage = "Invalid email or password. Please try again."
                    } else {
                        self.errorMessage = errorDesc
                    }
                    return
                }
                
                
                if let user = authResult?.user {
                    self.isEmailVerified = user.isEmailVerified
                }
                
                self.loginSuccess = true
            }
        }
    }
    
    func resetPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            errorMessage = "Please enter your email address to reset your password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        resetPasswordSuccessMessage = nil
        
        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.resetPasswordSuccessMessage = "Password reset email sent! Check your inbox."
                }
            }
        }
    }
}
