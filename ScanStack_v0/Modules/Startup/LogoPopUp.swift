//
//  LogoPopUp.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 18/05/2026.
//

/*
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
*/

import SwiftUI

struct LogoPopUp: View {
    // 1. Add state variables to trigger the animations
    @State private var animateBackground = false
    @State private var animateLogo = false
    @State private var animateLogoBack = false

    var body: some View {
        ZStack {
            backgroundGlows
            logoSection
        }
        // 2. Trigger the animations when the screen loads
        .onAppear {
            // Slow, continuous drifting for the background
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
            // Slightly faster, subtle pulsing for the logo
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateLogo = true
            }
            withAnimation(.spring(response: 2, dampingFraction: 0.7, blendDuration: 0)) {
                    animateLogoBack = true
                }
        }
    }
    
    // Grouping the background blobs keeps the main body clean
    @ViewBuilder
    private var backgroundGlows: some View {
        
        // Top Background Rectangle
        Rectangle()
            .fill(Color("btn_gradiant_color_0"))
            .frame(width: 300, height: 1000)
            .blur(radius: 200)
            .opacity(0.7)
            // 3. Shift the offset slightly based on the state
            .offset(x: 0, y: animateBackground ? -470 : -500)
        
        // Top Left Circle
        Circle()
            .fill(Color("btn_gradiant_color_1"))
            .frame(width: 150)
            .blur(radius: 90)
            .offset(x: animateBackground ? -130 : -150, y: animateBackground ? -380 : -400)
        
        // Bottom Background Rectangle
        Rectangle()
            .fill(Color("btn_gradiant_color_1"))
            .frame(width: 300, height: 1000)
            .blur(radius: 200)
            .opacity(0.7)
            .offset(x: 0, y: animateBackground ? 470 : 500)
        
        // Middle Right Circle
        Circle()
            .fill(Color("btn_gradiant_color_1"))
            .frame(width: 200)
            .blur(radius: 90)
            .opacity(0.5)
            .offset(x: animateBackground ? 120 : 140, y: animateBackground ? -160 : -180)
        
        // Bottom Left Circle
        Circle()
            .fill(Color("btn_gradiant_color_0"))
            .frame(width: 150)
            .opacity(0.3)
            .blur(radius: 90)
            .offset(x: animateBackground ? -130 : -150, y: animateBackground ? 280 : 300)
        
        // Bottom Right Circle
        Circle()
            .fill(Color("btn_gradiant_color_1"))
            .frame(width: 150)
            .opacity(0.5)
            .blur(radius: 90)
            .offset(x: animateBackground ? 130 : 150, y: animateBackground ? 280 : 300)
    }
    
    // Grouping the center logo components
    @ViewBuilder
    private var logoSection: some View {
        ZStack {
            Rectangle()
                .fill(Color("btn_gradiant_color_0"))
                .frame(width: 100, height: 100)
                .cornerRadius(18)
                .rotationEffect(.degrees(animateLogoBack ? 8 : 0))
                .offset(x: animateLogoBack ? 4 : 0, y: animateLogoBack ? 4 : 0)
            
            Rectangle()
                .fill(Color("LogoBack")) // Ensure this color exists in your assets!
                .frame(width: 100, height: 100)
                .cornerRadius(18)
                .rotationEffect(.degrees(animateLogoBack ? -8 : 0))
                .offset(x: animateLogoBack ? -4 : 0, y: animateLogoBack ? -4 : 0)
            
            Image("ScanStackLogo") // Ensure this image exists in your assets!
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        // Apply a subtle scaling pulse to the entire logo stack
        .scaleEffect(animateLogo ? 1.05 : 1.0)
    }
}

#Preview {
    LogoPopUp()
}
