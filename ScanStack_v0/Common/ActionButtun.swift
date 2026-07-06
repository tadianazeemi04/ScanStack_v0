//
//  ActionButtun.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 02/07/2026.
//

import Foundation
import SwiftUI

struct NavigationActionButton<Destination: View>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }
            .frame(width: 338, height: 68, alignment: .center)
            .background(
                LinearGradient(
                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(1000) // Keeps your precise layout capsule treatment
            .padding(.top, 10)
            .shadow(radius: 6)
            .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
        }
    }
}
