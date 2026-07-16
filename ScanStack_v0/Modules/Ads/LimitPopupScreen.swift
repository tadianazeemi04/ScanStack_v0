import SwiftUI

struct LimitPopupScreen: View {
    @Environment(\.dismiss) private var dismiss
    let onWatchAdSelected: () -> Void
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Top right close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Content
                VStack(spacing: 16) {
                    Image(systemName: "lock.rectangle.stack.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    
                    Text("Unlock Full Scan")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Extracting all screenshots requires massive processing power. Go Pro for unlimited access or watch a quick ad to unlock this single scan.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    
                    // Go Pro Button (Disabled per requirements)
                    Button {
                        // Action disabled for now
                    } label: {
                        Text("GO PRO (Coming Soon)")
                            .font(.system(size: 16, weight: .bold))
                            .kerning(1.2)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(30)
                    }
                    .disabled(true)
                    
                    // Watch Ad Button
                    Button {
                        dismiss()
                        // Small delay to allow the sheet to dismiss before triggering the full screen cover
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onWatchAdSelected()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.tv.fill")
                                .font(.system(size: 18))
                            Text("WATCH AD TO UNLOCK")
                                .font(.system(size: 16, weight: .bold))
                                .kerning(1.2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color("btn_gradiant_color_0"), Color("btn_gradiant_color_1")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: Color("btn_gradiant_color_1").opacity(0.3), radius: 10, x: 0, y: 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LimitPopupScreen(onWatchAdSelected: {})
}
