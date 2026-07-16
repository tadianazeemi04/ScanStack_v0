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
                // Top Header (Timer & Close Button)
                HStack {
                    if adFinished {
                        Button {
                            onAdCompleted()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    } else {
                        // Invisible placeholder so timer stays centered
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .opacity(0)
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
                    
                    // Invisible placeholder
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .opacity(0)
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
                        Text("Video/Image Ad Placeholder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
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
}

#Preview {
    AdScreen(onAdCompleted: {})
}
