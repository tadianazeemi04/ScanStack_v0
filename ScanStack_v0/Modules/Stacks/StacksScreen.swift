//
//  StacksDashboardScreen.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 13/07/2026.
//

import SwiftUI

struct StacksDashboardScreen: View {
    @StateObject private var viewModel = StacksViewModel()
    
    // State to control full-screen presentation of the collection screen
    @State private var showCollectionScreen = false
    
    // Selected category pill (mock functionality for UI)
    @State private var selectedCategory = "Recent"
    let categories = ["Recent", "All Stacks", "Food", "Emails"]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           
            // MARK: - Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedCategory == category ? .white : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategory == category
                                    ? Color("btn_gradiant_color_0")
                                    : Color("btn_gradiant_color_0").opacity(0.8) // Ideally a solid dark teal, matching mock
                                )
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            
            // MARK: - Grid Title
            Text("All Stacks")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // MARK: - 2x2 Grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Show up to 4 stacks in the dashboard
                    ForEach(viewModel.allStacks.prefix(4)) { stack in
                        DashboardStackCard(stack: stack)
                    }
                }
                .padding(.top, 4)
                
                // Add some space at the bottom for the tab bar and the big button
                Spacer().frame(height: 120)
            }
            .padding(.horizontal, 20)
            
        }
        .onAppear {
            viewModel.fetchStacks()
        }
        .overlay(
            // MARK: - See all stacks button (Floating at bottom)
            VStack {
                
                Button {
                    showCollectionScreen = true
                } label: {
                    Text("See all stacks")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .padding(.horizontal, 24)
                        .shadow(color: Color("btn_gradiant_color_1").opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 90) // Padding above the tab bar
                .padding(.top, 650) // Padding above the tab bar
            }
        )
        .fullScreenCover(isPresented: $showCollectionScreen) {
            StacksCollectionScreen()
        }
    }
}

// MARK: - Dashboard Stack Card
struct DashboardStackCard: View {
    let stack: StackGroup
    @State private var showInsideStack = false
    
    var body: some View {
        Button {
            showInsideStack = true
        } label: {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Group {
                        if let coverImage = stack.coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.clear],
                        startPoint: .bottom, endPoint: .center
                    )
                )
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stack.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(stack.count) images")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(16),
                    alignment: .bottomLeading
                )
                .clipped()
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showInsideStack) {
            InsideStackScreen(stack: stack)
        }
    }
}

#Preview {
    StacksDashboardScreen()
}
//
//  StacksScreen.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 11/07/2026.
//

import SwiftUI

struct StacksCollectionScreen: View {
    @StateObject private var viewModel = StacksViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStack: StackGroup?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Sticky Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Stacks Collection")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder for balance
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 20, weight: .semibold))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .ignoresSafeArea(edges: .top)
                )
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if viewModel.allStacks.isEmpty {
                            // MARK: - Empty State
                            VStack(spacing: 16) {
                                Image(systemName: "square.stack.3d.up.slash")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No Stacks Yet")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("Go to Activity and scan some images\nto see your stacks here!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            
                        } else {
                            // MARK: - Recently Section
                            if !viewModel.recentStacks.isEmpty {
                                Text("Recently")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.primary)
                                
                                ForEach(viewModel.recentStacks) { stack in
                                    Button {
                                        selectedStack = stack
                                    } label: {
                                        StackCardView(stack: stack)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // MARK: - Other Stacks Section
                            if !viewModel.otherStacks.isEmpty {
                                Text("Other Stacks")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.primary)
                                    .padding(.top, 4)
                                
                                ForEach(viewModel.otherStacks) { stack in
                                    Button {
                                        selectedStack = stack
                                    } label: {
                                        StackCardView(stack: stack)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Bottom padding for tab bar
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $selectedStack) { stack in
            InsideStackScreen(stack: stack)
        }
        .onAppear {
            viewModel.fetchStacks()
        }
    }
}
// MARK: - Stack Card View (used in the collection list)
struct StackCardView: View {
    let stack: StackGroup
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Cover Image
            if let coverImage = stack.coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
            } else {
                // Fallback gradient if no images
                LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .overlay(
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 36))
                        .foregroundColor(.gray.opacity(0.5))
                )
            }
            
            // Bottom gradient overlay for text readability
            LinearGradient(
                colors: [Color.black.opacity(0.7), Color.clear],
                startPoint: .bottom, endPoint: .center
            )
            .frame(height: 100)
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            // Stack name + count
            VStack(alignment: .leading, spacing: 2) {
                Text(stack.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("\(stack.count) images")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
        }
        .frame(height: 180)
        .cornerRadius(16)
        .clipped()
    }
}

#Preview {
    StacksCollectionScreen()
}
