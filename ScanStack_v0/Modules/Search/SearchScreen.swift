import SwiftUI

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedDocument: ScannedDocument?
    
    // Grid configuration matching InsideStackScreen
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("Search")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // MARK: - Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search OCR text or stacks...", text: $viewModel.searchText)
                    .foregroundColor(.primary)
                    .disableAutocorrection(true)
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(36)
            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // MARK: - Content Area
            if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Empty State
                emptyStateView
            } else if viewModel.searchResults.isEmpty {
                // No Results State
                noResultsView
            } else {
                // Results Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.searchResults, id: \.id) { doc in
                            ImageThumbnailView(document: doc)
                                .onTapGesture {
                                    selectedDocument = doc
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Padding for tab bar
                }
            }
        }
        // Assuming ScannedDocument conforms to Identifiable via CoreData extension
        .fullScreenCover(item: $selectedDocument) { doc in
            ImagePreview(document: doc)
        }
    }
    
    // MARK: - Helper Views
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.8)
            
            Text("Search your Documents")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Find items by their extracted text or category. Start typing above.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No results found")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Try searching for different keywords or checking your spelling.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

#Preview {
    SearchScreen()
}
