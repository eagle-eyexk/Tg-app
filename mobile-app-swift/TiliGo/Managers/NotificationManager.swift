import Foundation
import UserNotifications

/// Manages local and push notifications for the app
class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        setupNotificationDelegate()
    }
    
    // MARK: - Setup
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Setup notifications in AppDelegate - call this from AppDelegate.application(_:didFinishLaunchingWithOptions:)
    func setupNotifications() {
        PermissionManager.shared.requestNotificationPermission { granted in
            print("[NotificationManager] Notification permission: \(granted)")
        }
    }
    
    // MARK: - Local Notifications
    
    /// Show a local notification
    func showLocalNotification(title: String, body: String, delay: TimeInterval = 2, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Add custom data
        content.userInfo = [
            "notificationType": "local",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Create trigger for delayed notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling notification: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// Show notification with custom data
    func showNotification(title: String, body: String, data: [String: Any]? = nil, delay: TimeInterval = 2, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var userInfo: [AnyHashable: Any] = [
            "notificationType": "custom",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let data = data {
            userInfo["customData"] = data
        }
        
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            completion(error == nil)
        }
    }
    
    /// Remove all pending notifications
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Remove specific notification
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Get all pending notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    // MARK: - Remote Notifications
    
    /// Register for remote notifications (push notifications)
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /// Handle device token for push notifications (called from AppDelegate)
    func handleDeviceToken(_ token: Data) {
        let tokenParts = token.map { data in String(format: "%02.2hhx", data) }
        let deviceToken = tokenParts.joined()
        print("[NotificationManager] Device token: \(deviceToken)")
        
        // Store or send to server
        // UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
    }
    
    /// Handle remote notification (called from AppDelegate)
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        print("[NotificationManager] Remote notification received: \(userInfo)")
    }
    
    // MARK: - Badge Management
    
    /// Set app badge count
    func setAppBadge(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    /// Clear app badge
    func clearAppBadge() {
        setAppBadge(0)
    }
    
    /// Increment app badge
    func incrementBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("[NotificationManager] Foreground notification: \(userInfo)")
        
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// Handle notification tap when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("[NotificationManager] Background notification tapped: \(userInfo)")
        
        // Handle notification action
        // Send to web app via NativeBridge
        
        completionHandler()
    }
}
