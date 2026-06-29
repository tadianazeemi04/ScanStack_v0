//
//  Welcome_1.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 18/05/2026.
//

import SwiftUI

struct Welcome_1: View {
    var body: some View {
        NavigationStack { // 1. Added NavigationStack to power the NavigationLink
            ZStack (alignment: .top) {
                // Background Layer
                Color("AccentColor")
                    .ignoresSafeArea()
                
                // Content Layer
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
                    
                    
                    
                    VStack{
                        
                        // Intro Card first page
                        ZStack {
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
                            
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.gray.opacity(0.05))
                                    .frame(width: 150, height: 258)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                                    .rotationEffect(.degrees(14))
                                    .offset(x : 70, y : 10)
                            
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.gray.opacity(0.05))
                                    .frame(width: 150, height: 258)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                                    .rotationEffect(.degrees(-14))
                                    .offset(x : -70, y : 10)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 224, height: 258)
                                .cornerRadius(32)
                            
                            VStack(alignment: .leading, spacing: 20){
                                
                                ZStack{
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 190, height: 128)
                                        .cornerRadius(16)
                                    Image("welcome1")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 190, height: 128)
                                        .opacity(0.6)
                                        .blendMode(.overlay)
                                        .cornerRadius(16)
                                        .clipped()
                                    Image("welcome1_ai")
                                        .clipped()
                                }
                                    
                                        VStack(alignment: .leading, spacing: 10) {
                                            Capsule()
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 160, height: 8)
                                            
                                            Capsule()
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 100, height: 8)
                                        }
                                        
                                        
                                        HStack(spacing: 12) {
                                           
                                            Capsule()
                                                .fill(Color.cyan)
                                                .frame(width: 28, height: 6)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Capsule().fill(Color.cyan.opacity(0.2)))
                                            
                                           
                                            Capsule()
                                                .fill(Color.purple.opacity(0.6))
                                                .frame(width: 28, height: 6)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Capsule().fill(Color.purple.opacity(0.15)))
                                        }
                                }
                            }
                        }
                    
                    //welcome 1 details
                    
                    VStack(alignment: .center){
                        Text("Stop digging")
                            .font(.system(size: 36, weight: .heavy, design: .default))
                            .foregroundColor(Color(hex: "2C2F31"))
                        
                        Text("Start Finding")
                            .font(.system(size: 36, weight: .heavy, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                        
                        Text("Your gallery is full of information. ScanStack uses AI to read your screenshots and organize them automatically.")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "595C5E"))
                            .frame(width: 283, height: 117)
                            .multilineTextAlignment(.center)
                            .lineHeight(.loose)
                    }
                    
                    // next screen navigation buttun
                    
                    VStack(alignment: .center){
                        HStack(alignment: .center)
                        {
                            Capsule()
                                .fill(Color(hex: "006289"))
                                .frame(width: 28, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top, 40)
                            
                            Capsule()
                                .fill(Color(hex: "ABADAF"))
                                .frame(width: 6, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top, 40)
                            
                            Capsule()
                                .fill(Color(hex: "ABADAF"))
                                .frame(width: 6, height: 6)
                                .padding(.horizontal, -2)
                                .padding(.top, 40)
                        }
                        
                        Button{
                            //navigation here
                        } label: {
                            HStack(alignment: .center){
                                Text("Next")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "arrowshape.right.fill")
                                    .font(.system(size: 16))
                                
                            }
                            .frame(width: 338, height: 68, alignment: .center)
                            .background(
                                LinearGradient(colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(1000)
                            .padding(.top, 10)
                            .shadow(radius: 6)
                            .shadow(color: Color.btnGradiantColor1.opacity(0.3), radius: 6, x : 2, y : 2)
                            
                        }
                    }
                    
                    }
                
                // Model Badges
                            Image("classified")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 77)
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                                .offset(x: 95, y: 180)
                            
                            Image("extraction")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 77)
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                                .offset(x: -95, y: 265)
                }
            }
        }
    }


#Preview {
    Welcome_1()
}

