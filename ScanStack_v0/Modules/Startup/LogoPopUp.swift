//
//  LogoPopUp.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 18/05/2026.
//

import SwiftUI

struct LogoPopUp: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("btn_gradiant_color_0"))
                .frame(width: 300, height: 1000)
                .blur(radius: 200)
                .opacity(0.7)
                .offset(x:0, y: -500)
            Circle()
                .fill(Color("btn_gradiant_color_1"))
                .frame(width: 150)
                .blur(radius: 90)
                .offset(x:-150, y: -400)
            Rectangle()
                .fill(Color("btn_gradiant_color_1"))
                .frame(width: 300, height: 1000)
                .blur(radius: 200)
                .opacity(0.7)
                .offset(x:0, y: 500)
            Circle()
                .fill(Color("btn_gradiant_color_1"))
                .frame(width: 200)
                .blur(radius: 90)
                .opacity(0.5)
                .offset(x:140, y: -180)
            Circle()
                .fill(Color("btn_gradiant_color_0"))
                .frame(width: 150)
                .opacity(0.3)
                .blur(radius: 90)
                .offset(x:-150, y: 300)
            Circle()
                .fill(Color("btn_gradiant_color_1"))
                .frame(width: 150)
                .opacity(0.5)
                .blur(radius: 90)
                .offset(x:150, y: 300)
            Rectangle()
                .fill(Color("btn_gradiant_color_0"))
                .frame(width: 100, height: 100)
                .cornerRadius(18)
                .rotationEffect(.degrees(8))
                .offset(x:4, y:4)
            Rectangle()
                .fill(Color("LogoBack"))
                .frame(width: 100, height: 100)
                .cornerRadius(18)
                .rotationEffect(.degrees(-8))
                .offset(x:-4, y:-4)
            Image("ScanStackLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    LogoPopUp()
}
