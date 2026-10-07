//
//  ProfileImageManager.swift
//  ScanStack_v0
//
//  Created for ScanStack profile picture management.
//

import UIKit
import FirebaseAuth
import Combine

@MainActor
class ProfileImageManager: ObservableObject {
    static let shared = ProfileImageManager()
    
    @Published var profileImage: UIImage? = nil
    
    private let fileName = "profile_picture.jpg"
    
    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }
    
    init() {
        loadSavedProfileImage()
    }
    
    /// Loads saved profile image from local disk if it exists
    func loadSavedProfileImage() {
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            self.profileImage = image
        }
    }
    
    /// Saves a newly selected profile image to disk and updates Firebase Auth if available
    func saveProfileImage(_ image: UIImage) {
        self.profileImage = image
        
        guard let url = fileURL,
              let data = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        do {
            try data.write(to: url)
            print("✅ Profile image saved to: \(url.path)")
            
            // Optionally update Firebase photoURL to point to local file scheme
            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = url
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("⚠️ Failed to update Firebase photoURL: \(error.localizedDescription)")
                    } else {
                        print("✅ Firebase user photoURL updated.")
                    }
                }
            }
        } catch {
            print("❌ Failed to save profile image: \(error.localizedDescription)")
        }
    }
    
    /// Clears saved profile image (e.g. on user logout)
    func clearProfileImage() {
        self.profileImage = nil
        if let url = fileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
