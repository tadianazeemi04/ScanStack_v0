import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var dateOfBirth = ""
    @Published var selectedDate = Date()
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var registrationSuccess = false
    
    // Validation for first screen (Registration)
    func validateRegistrationDetails() -> Bool {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Full Name is required."
            return false
        }
        
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
        
        if dateOfBirth.isEmpty {
            errorMessage = "Date of Birth is required."
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    // Validation for second screen (Security)
    func validatePassword() -> Bool {
        if password.isEmpty {
            errorMessage = "Password is required."
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    func registerUser() {
        guard validateRegistrationDetails(), validatePassword() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to retrieve user information."
                }
                return
            }
            
            // Send email verification
            user.sendEmailVerification { error in
                if let error = error {
                    print("Error sending email verification: \(error.localizedDescription)")
                }
            }
            
            // Save additional user details to Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "uid": user.uid,
                "fullName": self.fullName,
                "email": trimmedEmail,
                "dateOfBirth": self.dateOfBirth,
                "createdAt": Timestamp(date: Date())
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    } else {
                        self.registrationSuccess = true
                    }
                }
            }
        }
    }
}
