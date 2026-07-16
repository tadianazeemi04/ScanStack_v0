import Foundation
import CoreData
import FirebaseAuth
import Combine

struct StorageInsight: Identifiable {
    let id = UUID()
    let category: String
    let sizeBytes: Int64
    let colorHex: String
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: sizeBytes)
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var displayName: String = "User Name"
    @Published var email: String = "user@example.com"
    @Published var profilePhotoURL: URL? = nil
    
    @Published var totalStorageUsedBytes: Int64 = 0
    @Published var totalStorageCapacityBytes: Int64 = 128 * 1024 * 1024 * 1024 // Fake 128GB total for mockup purposes
    @Published var storageInsights: [StorageInsight] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        fetchUserProfile()
        calculateStorage()
    }
    
    func fetchUserProfile() {
        if let user = Auth.auth().currentUser {
            self.displayName = user.displayName ?? "User Name"
            self.email = user.email ?? "useremail@gmail.com"
            self.profilePhotoURL = user.photoURL
        }
    }
    
    func calculateStorage() {
        let request: NSFetchRequest<ScannedDocument> = ScannedDocument.fetchRequest()
        
        do {
            let allDocs = try context.fetch(request)
            var totalSize: Int64 = 0
            var categorySizes: [String: Int64] = [:]
            
            let fileManager = FileManager.default
            guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            for doc in allDocs {
                guard let imageName = doc.imageName else { continue }
                let filePath = documentsPath.appendingPathComponent(imageName).path
                
                if let attr = try? fileManager.attributesOfItem(atPath: filePath),
                   let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                    
                    let size = Int64(fileSize)
                    totalSize += size
                    
                    let catName = doc.stackName ?? "Uncategorized"
                    categorySizes[catName, default: 0] += size
                }
            }
            
            self.totalStorageUsedBytes = totalSize
            
            // Get top 2 categories by size for the breakdown, assign colors
            let sortedCategories = categorySizes.sorted { $0.value > $1.value }.prefix(2)
            let colors = ["006D8A", "8E24AA", "1B5E20"] // Hex colors for the segments
            
            var insights: [StorageInsight] = []
            for (index, cat) in sortedCategories.enumerated() {
                let color = index < colors.count ? colors[index] : "000000"
                insights.append(StorageInsight(category: cat.key, sizeBytes: cat.value, colorHex: color))
            }
            
            self.storageInsights = insights
            
        } catch {
            print("Error calculating storage: \(error.localizedDescription)")
        }
    }
    
    var formattedTotalUsed: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalStorageUsedBytes)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // The AppStorage observer in StartupView/MainTabBar will catch this and kick them to login
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
