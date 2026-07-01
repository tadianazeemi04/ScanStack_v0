//
//  Welcome_2.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 19/05/2026.
//

import SwiftUI

struct Welcome_2: View {
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                // Background Layer
                Color("AccentColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
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
                        
                        NavigationLink(destination: Registeration()) {
                            Text("Skip")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("skip_btn"))
                        }
                        .padding(.horizontal, 20)
                        
                    }
                    
                    //cards design
                    
                    ZStack{
                        
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 370, height: 328)
                            .opacity(0.25)
                            .blur(radius: 64)
                            .offset(x:0,y:0)
                        //rectangles cards
                        Rectangle()
                            .fill(
                                LinearGradient(colors: [Color("btn_gradiant_color_0").opacity(0.2), Color("btn_gradiant_color_1").opacity(0.2)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(48)
                            .frame(width: 312, height: 322)
                            .rotationEffect(.degrees(8))
                            .padding(.top)
                        
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.white)
                            .frame(width: 326, height: 268)
                            .overlay(RoundedRectangle(cornerRadius: 32)
                                .stroke(Color(hex: "ABADAF").opacity(0.2), lineWidth: 1.4))
                            .padding(.top)
                        
                        // text skelton capsules
                        VStack(alignment: .center){
                            
                            HStack(alignment: .center){
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 96, height: 16)
                                Spacer()
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 48, height: 16)
                            }
                            .frame(width: 260)
                            .padding(.top, -10)
                            .padding(.bottom, 20)
                            
                            VStack(alignment: .leading){
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 260, height: 12)
                                
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 260, height: 12)
                                
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 180, height: 12)
                            }
                            .padding(.bottom,30)
                            
                            VStack(alignment: .leading){
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 260, height: 12)
                                
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 180, height: 12)
                                
                                Capsule()
                                    .fill(Color(hex: "DADDE0").opacity(0.6))
                                    .frame(width: 190, height: 12)
                            }
                        }
                        .frame(width: 260)
                        
                        ZStack{
                            VStack(alignment: .leading, spacing: 2) {
                                Text("TEXT DETECTED")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "006289"))
                                
                                Text("Total: Rs.124.53")
                                    .font(.system(size: 22, weight: .heavy))
                                    .foregroundColor(Color(hex: "2C2F31"))
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background {
                                ZStack {
                                    // 1. Core Glass Blur Layer
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                    
                                    // 2. Translucent Colorful Tint Layer (Matches the subtle blue/purple gradient look)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "2DBCFE").opacity(0.08),
                                                    Color(hex: "A370F7").opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // 3. 3D Specular Inner Glow (Simulating light hitting the top edge)
                                    Capsule()
                                        .stroke(Color.white.opacity(0.65), lineWidth: 1.5)
                                        .blur(radius: 0.5)
                                        .mask(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.white, .clear],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                        )
                                }
                            }
                            // 4. Physical Outer Gradient Border
                            .overlay {
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "2DBCFE").opacity(0.8),
                                                Color(hex: "A370F7").opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            // 5. Soft Ambient Colored Drop Shadow
                            .shadow(color: Color(hex: "A370F7").opacity(0.12), radius: 12, x: 0, y: 8)
                        }
                        .offset(x: -20, y: 80)
                        
                        ZStack{
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color("btn_gradiant_color_0").opacity(1),
                                            Color("btn_gradiant_color_1").opacity(1)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 80, height: 30)
                            
                            Text("AI VISION")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(Color("btn_gradiant_color_1"))
                            
                                .padding()
                            //.glassEffect(in: RoundedRectangle(cornerRadius: 16))
                                .glassEffect()
                                .overlay{
                                    Capsule()
                                        .stroke(LinearGradient(colors: [Color(.white)], startPoint: .top, endPoint: .bottom),
                                                lineWidth: 2.5)
                                }
                                .frame(width: 108, height: 50)
                            
                            
                        }
                        .offset(x: 90, y: 50)
                        
                    }
                    
                    VStack(alignment: .center){
                        Text("Search Inside")
                            .font(.system(size: 36, weight: .heavy, design: .default))
                            .foregroundColor(Color(hex: "2C2F31"))
                        
                        Text("Your Photos")
                            .font(.system(size: 36, weight: .heavy, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                        
                        Text("ScanStack instantly turns text, numbers, and details within your screenshots into searchable information, organizing your gallery automatically.")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "595C5E"))
                            .frame(width: 360, height: 108)
                            .multilineTextAlignment(.center)
                            .lineHeight(.loose)
                    }
                    .padding(.top)
                    
                    VStack(alignment: .center){
                        HStack(alignment: .center)
                        {
                            Capsule()
                                .fill(Color(hex: "ABADAF"))
                                .frame(width: 6, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top)
                            
                            Capsule()
                                .fill(Color(hex: "006289"))
                                .frame(width: 28, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top)
                            
                            Capsule()
                                .fill(Color(hex: "ABADAF"))
                                .frame(width: 6, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top)
                        }
                        
                        NavigationLink(destination: Welcome_3()) {
                            HStack(alignment: .center) {
                                Text("Next")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "arrowshape.right.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white) // Added to match the text
                            }
                            .frame(width: 338, height: 68, alignment: .center)
                            .background(
                                LinearGradient(
                                    colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(1000)
                            .padding(.top, 10)
                            .shadow(radius: 6)
                            .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 6, x: 2, y: 2)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Welcome_2()
}
