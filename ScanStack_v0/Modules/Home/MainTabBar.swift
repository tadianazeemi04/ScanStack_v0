//
//  MainTabBar.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 11/07/2026.
//

import SwiftUI
import FirebaseAuth

enum MainTab {
    case home, activity, search, stacks
}

struct MainTabBar: View {
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        
        ZStack{
            Color("AccentColor")
                .ignoresSafeArea()
            
            VStack{
                HStack {
                    Text("ScanStack")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Profile Image
                    Menu {
                        Button(action: {
                            // Settings action will go here
                        }) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        
                        Button(role: .destructive, action: {
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                print("Error signing out: \\(error.localizedDescription)")
                            }
                        }) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        if let photoURL = Auth.auth().currentUser?.photoURL {
                            AsyncImage(url: photoURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 44, height: 44)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(Color(hex: "595C5E"))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal, 20)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(Color(hex: "595C5E"))
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .padding(.horizontal, 20)
                        }
                    }
                } // Closes HStack
                
                // Content Area
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeScreen()
                    case .activity:
                        Text("Activity Screen")
                    case .search:
                        Text("Search Screen")
                    case .stacks:
                        Text("Stacks Screen")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                //main tab bar
                HStack{
                    
                    // HOME button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .home
                        }
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundStyle(selectedTab == .home ? Color.menuTabBtnBg : Color.clear)
                                .frame(width: 86)
                                .cornerRadius(30)
                                .frame(height: 56)
                            
                            VStack(alignment: .center) {
                                Image("Home_icon")
                                    .renderingMode(.template)
                                    .foregroundColor(selectedTab == .home ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                                Text("HOME")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .home ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                            }
                        }
                    }
                    
                    Spacer()
                    // ACTIVITY button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .activity
                        }
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundStyle(selectedTab == .activity ? Color.menuTabBtnBg : Color.clear)
                                .frame(width: 86)
                                .cornerRadius(30)
                                .frame(height: 56)

                            VStack(alignment: .center) {
                                Image("Activity_icon")
                                    .renderingMode(.template)
                                    .foregroundColor(selectedTab == .activity ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                                Text("ACTIVITY")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .activity ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // SEARCH button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .search
                        }
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundStyle(selectedTab == .search ? Color.menuTabBtnBg : Color.clear)
                                .frame(width: 86)
                                .cornerRadius(30)
                                .frame(height: 56)

                            VStack(alignment: .center) {
                                Image("Search_icon")
                                    .renderingMode(.template)
                                    .foregroundColor(selectedTab == .search ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                                Text("SEARCH")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .search ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // STACKS button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .stacks
                        }
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundStyle(selectedTab == .stacks ? Color.menuTabBtnBg : Color.clear)
                                .frame(width: 86)
                                .cornerRadius(30)
                                .frame(height: 56)

                            VStack(alignment: .center) {
                                Image("Stacks_icon")
                                    .renderingMode(.template)
                                    .foregroundColor(selectedTab == .stacks ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                                Text("STACKS")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .stacks ? Color.menuTabBarEnableBtn : Color.menuTabDisableBtn)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .background(
                    Rectangle()
                    //                .padding(20)
                        .foregroundStyle(Color(hex: "FBFBFC"))
                        .frame(width: 378)
                        .cornerRadius(50)
                        .frame(height: 70)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 5)
                )
                
            }
        }
    }
}

#Preview {
    MainTabBar()
}
