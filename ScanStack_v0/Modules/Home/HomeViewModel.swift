import Foundation
import CoreData
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var totalScans: Int = 0
    @Published var totalStacks: Int = 0
    @Published var recentScans: [ScannedDocument] = []
    @Published var displayName: String = "User"
    @Published var profilePhotoURL: URL? = nil
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        fetchDashboardData()
        fetchDisplayName()
    }
    
    func fetchDisplayName() {
        if let user = Auth.auth().currentUser {
            self.profilePhotoURL = user.photoURL
            
            if let name = user.displayName, !name.isEmpty {
                // If full name is "John Doe", just take "John"
                let firstName = name.components(separatedBy: " ").first ?? "User"
                self.displayName = firstName
            } else if let email = user.email {
                let prefix = email.components(separatedBy: "@").first ?? "User"
                self.displayName = prefix.capitalized
            }
        }
    }
    
    func fetchDashboardData() {
        let request: NSFetchRequest<ScannedDocument> = ScannedDocument.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScannedDocument.dateCreated, ascending: false)]
        
        do {
            let allDocs = try context.fetch(request)
            totalScans = allDocs.count
            
            // Calculate total unique stacks
            let uniqueStacks = Set(allDocs.compactMap { $0.stackName })
            totalStacks = uniqueStacks.count
            
            // Get up to 10 most recent scans
            recentScans = Array(allDocs.prefix(10))
            
        } catch {
            print("Error fetching home data: \(error.localizedDescription)")
            totalScans = 0
            totalStacks = 0
            recentScans = []
        }
    }
}
