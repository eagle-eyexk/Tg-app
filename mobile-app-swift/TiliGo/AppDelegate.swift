import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        // Setup notifications
        NotificationManager.shared.setupNotifications()
        
        // Handle deep links from notifications
        if let notificationPayload = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            handleRemoteNotification(notificationPayload)
        }
        
        return true
    }
    
    // MARK: - Deep Linking
    
    /// Handle URL schemes
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("[AppDelegate] Opening URL: \(url.absoluteString)")
        
        // Get the current view controller
        if let viewController = window?.rootViewController as? ViewController {
            viewController.handleDeepLink(url: url)
        }
        
        return true
    }
    
    // MARK: - Push Notifications
    
    /// Handle device token registration
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.handleDeviceToken(deviceToken)
    }
    
    /// Handle registration failure
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// Handle remote notification in background
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("[AppDelegate] Remote notification received in background")
        handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }
    
    // MARK: - Notification Handling
    
    private func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationManager.shared.handleRemoteNotification(userInfo)
        
        // Handle deep link if present in notification
        if let deepLink = userInfo["deepLink"] as? String,
           let url = URL(string: deepLink) {
            if let viewController = window?.rootViewController as? ViewController {
                viewController.handleDeepLink(url: url)
            }
        }
    }
}
