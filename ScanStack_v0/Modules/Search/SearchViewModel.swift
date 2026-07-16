import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [ScannedDocument] = []
    
    private let context = PersistenceController.shared.container.viewContext
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search text to avoid rapid CoreData queries on every keystroke
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            return
        }
        
        let request: NSFetchRequest<ScannedDocument> = ScannedDocument.fetchRequest()
        
        // Search in extractedText OR stackName
        let predicate = NSPredicate(format: "extractedText CONTAINS[cd] %@ OR stackName CONTAINS[cd] %@", trimmedQuery, trimmedQuery)
        request.predicate = predicate
        
        // Sort by newest first
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScannedDocument.dateCreated, ascending: false)]
        
        do {
            searchResults = try context.fetch(request)
        } catch {
            print("Error executing search fetch request: \(error.localizedDescription)")
            searchResults = []
        }
    }
}
