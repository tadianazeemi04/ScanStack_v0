import Foundation
import Combine
import GoogleMobileAds
import UIKit

class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = RewardedAdManager()
    @Published var rewardedAd: RewardedAd?
    
    // Testing Ad Unit ID
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    // State management for auto-redirect
    private var autoDismissTimer: Timer?
    private var rewardCompletionHandler: (() -> Void)?
    private var hasTriggeredCompletion = false
    
    override init() {
        super.init()
    }
    
    func loadAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("✅ Rewarded ad loaded successfully.")
        }
    }
    
    func showAd(rewardCompletion: @escaping () -> Void) {
        guard let windowScene = getWindowScene(),
              let rootViewController = getRootViewController() else {
            print("Root VC or Window Scene not found")
            rewardCompletion()
            return
        }
        
        guard let ad = rewardedAd else {
            print("Ad wasn't ready, bypassing ad to prevent locking user out")
            rewardCompletion()
            loadAd()
            return
        }
        
        // Reset state for new ad presentation
        self.rewardCompletionHandler = rewardCompletion
        self.hasTriggeredCompletion = false
        ad.fullScreenContentDelegate = self
        
        ad.present(from: rootViewController) { [weak self] in
            print("✅ Google SDK reward callback earned.")
        }
        
        // Auto-redirect after 30 seconds if Google's test ad cross button doesn't appear
        autoDismissTimer?.invalidate()
        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            print("⏱️ 30 seconds reached for rewarded ad: auto-redirecting user back to the app.")
            self?.dismissCurrentAd()
        }
    }
    
    // MARK: - Ad Dismissal & Redirection
    func dismissCurrentAd() {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        
        // Find the top-most modal view controller presented on the root VC and dismiss it
        if let rootVC = getRootViewController() {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            if topVC !== rootVC {
                topVC.dismiss(animated: true) { [weak self] in
                    self?.triggerRewardCompletion()
                }
                loadAd()
                return
            }
        }
        
        triggerRewardCompletion()
        loadAd()
    }
    
    private func triggerRewardCompletion() {
        guard !hasTriggeredCompletion else { return }
        hasTriggeredCompletion = true
        DispatchQueue.main.async { [weak self] in
            self?.rewardCompletionHandler?()
            self?.rewardCompletionHandler = nil
        }
    }
    
    // MARK: - Helpers
    private func getWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        return scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? scenes.first as? UIWindowScene
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = getWindowScene() else { return nil }
        return windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? windowScene.windows.first?.rootViewController
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed by SDK delegate")
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        triggerRewardCompletion()
        loadAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        triggerRewardCompletion()
        loadAd()
    }
}
