//
//  Welcome_3.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 19/05/2026.
//

import SwiftUI

struct Welcome_3: View {
    var body: some View {
        ZStack(alignment: .top){
            // Background Layer
            Color("AccentColor")
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                
                // logo bar
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
                }
                
                VStack(alignment: .center){
                    Image("welcome3")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 338, height: 326)
                        .opacity(1)
                        .clipped()
                        .padding(.bottom, 0)
                    Text("Secure &")
                        .font(.system(size: 36, weight: .heavy, design: .default))
                        .foregroundColor(Color(hex: "2C2F31"))
                    
                    Text("Actionable")
                        .font(.system(size: 36, weight: .heavy, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "006289"), Color(hex: "831BD7")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                    
                    Text("Protect sensitive docs with FaceID and take action on links or numbers with one tap. Your data stays 100% on your device.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(Color(hex: "595C5E"))
                        .frame(width: 303, height: 117)
                        .multilineTextAlignment(.center)
                        .lineHeight(.loose)
                }
                
                // navigation bar
                VStack(alignment: .center){
                    HStack(alignment: .center)
                    {
                        Capsule()
                            .fill(Color(hex: "ABADAF"))
                            .frame(width: 6, height: 6)
                            .padding(.horizontal, -2)
                            .padding(.top)
                        
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
                    }
                    
                    NavigationLink(destination: Registeration()) {
                        HStack(alignment: .center) {
                            Text("Get Started")
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
    
#Preview {
    Welcome_3()
}
