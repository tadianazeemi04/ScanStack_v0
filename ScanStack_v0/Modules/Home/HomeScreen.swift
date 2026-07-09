//
//  HomeScreen.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 01/07/2026.
//

import SwiftUI

import FirebaseAuth

struct HomeScreen: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to ScanStack!")
                .font(.title)
                .fontWeight(.bold)
            
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    isLoggedIn = false
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
