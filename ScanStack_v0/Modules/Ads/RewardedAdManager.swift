import Foundation
import Combine
import GoogleMobileAds
import UIKit

class RewardedAdManager: ObservableObject {
    static let shared = RewardedAdManager()
    @Published var rewardedAd: RewardedAd?
    
    // Always use Google's Test ID during development!
    private let testAdUnitID = "ca-app-pub-3940256099942544/1712485313" 
    
    func loadAd() {
        let request = Request()
        RewardedAd.load(with: testAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
        }
    }
    
    func showAd(rewardCompletion: @escaping () -> Void) {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Root VC not found")
            return
        }
        
        guard let ad = rewardedAd else {
            print("Ad wasn't ready, bypassing ad to prevent locking user out")
            rewardCompletion()
            loadAd()
            return
        }
        
        ad.present(from: rootViewController) {
            // Ensure the reward triggers on the main UI thread to prevent crashes
            DispatchQueue.main.async {
                rewardCompletion()
            }
        }
        
        // Immediately load the next ad so it's ready for next time
        loadAd() 
    }
}
