//
//  StacksViewModel.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 13/07/2026.
//

import SwiftUI
import CoreData
import Combine

/// Represents a single stack (category) with its documents
struct StackGroup: Identifiable {
    let id = UUID()
    let name: String
    let documents: [ScannedDocument]
    
    var count: Int { documents.count }
    
    /// Returns the first image from the stack for the cover
    var coverImage: UIImage? {
        guard let imageName = documents.first?.imageName else { return nil }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName)
        return UIImage(contentsOfFile: path.path)
    }
    
    /// Most recent date in this stack
    var latestDate: Date {
        documents.compactMap { $0.dateCreated }.max() ?? Date.distantPast
    }
}

@MainActor
class StacksViewModel: ObservableObject {
    @Published var recentStacks: [StackGroup] = []
    @Published var otherStacks: [StackGroup] = []
    @Published var allStacks: [StackGroup] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("FavoritesChanged"), object: nil, queue: .main) { [weak self] _ in
            self?.fetchStacks()
        }
    }
    
    func fetchStacks() {
        let request: NSFetchRequest<ScannedDocument> = ScannedDocument.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScannedDocument.dateCreated, ascending: false)]
        
        do {
            let allDocs = try context.fetch(request)
            
            // Group by stackName
            let grouped = Dictionary(grouping: allDocs) { $0.stackName ?? "Uncategorized" }
            
            var stacks = grouped.map { StackGroup(name: $0.key, documents: $0.value) }
                .sorted { $0.latestDate > $1.latestDate }
            
            // Inject "My Favorite" stack if there are favorites
            let favoriteIDs = UserDefaults.standard.stringArray(forKey: "FavoriteDocumentIDs") ?? []
            let favoriteDocs = allDocs.filter { doc in
                if let idString = doc.id?.uuidString {
                    return favoriteIDs.contains(idString)
                }
                return false
            }
            
            let favoriteStack = StackGroup(name: "My Favorite", documents: favoriteDocs)
            // Remove it if it somehow exists to avoid duplicates, then prepend
            stacks.removeAll { $0.name == "My Favorite" }
            stacks.insert(favoriteStack, at: 0)
            
            self.allStacks = stacks
            
            // "Recently" = top 2 most recent stacks
            self.recentStacks = Array(stacks.prefix(2))
            
            // "Other Stacks" = the rest
            self.otherStacks = Array(stacks.dropFirst(2))
            
        } catch {
            print("Error fetching stacks: \(error.localizedDescription)")
        }
    }
}
