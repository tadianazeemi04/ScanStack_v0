import SwiftUI
import Combine

struct AdScreen: View {
    let onAdCompleted: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining = 30
    @State private var adFinished = false
    
    // Use a timer that fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top Header (Timer & Manual Close Button)
                HStack {
                    // Manual Close Button: Always available so user is never trapped
                    Button {
                        handleExit()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                            if adFinished {
                                Text("Close")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    if !adFinished {
                        Text("Ad ends in \(timeRemaining)s")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    } else {
                        Text("Reward Granted")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Quick Return button on right as well
                    Button {
                        handleExit()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Ad Content Placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        Text(adFinished ? "Reward Unlocked!" : "Video/Image Ad Placeholder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Manual return button at the bottom
                Button {
                    handleExit()
                } label: {
                    Text(adFinished ? "Return to App" : "Skip Ad & Return")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            adFinished
                            ? LinearGradient(colors: [Color.green, Color.teal], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(24)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                adFinished = true
                timer.upstream.connect().cancel()
            }
        }
    }
    
    private func handleExit() {
        onAdCompleted()
        dismiss()
    }
}

#Preview {
    AdScreen(onAdCompleted: {})
}
