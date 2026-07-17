import Foundation
import UIKit
import LocalAuthentication

/// Provides device information to the web app
struct DeviceInfo {
    
    /// Get comprehensive device information
    static func getDeviceInfo() -> [String: Any] {
        return [
            "platform": "iOS",
            "osVersion": UIDevice.current.systemVersion,
            "appVersion": getAppVersion(),
            "deviceModel": UIDevice.current.model,
            "deviceName": UIDevice.current.name,
            "screenSize": getScreenSize(),
            "locale": Locale.current.identifier,
            "timezone": TimeZone.current.identifier,
            "biometryType": getBiometryType(),
            "biometryAvailable": isBiometryAvailable(),
            "hasNotchOrDynamicIsland": hasNotchOrDynamicIsland(),
            "safeAreaInsets": getSafeAreaInsets()
        ]
    }
    
    /// Get app version and build number
    private static func getAppVersion() -> [String: String] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        return [
            "version": appVersion,
            "build": buildNumber
        ]
    }
    
    /// Get screen size information
    private static func getScreenSize() -> [String: Any] {
        let screen = UIScreen.main
        return [
            "width": Int(screen.bounds.width),
            "height": Int(screen.bounds.height),
            "scale": Int(screen.scale),
            "nativeScale": Int(screen.nativeScale)
        ]
    }
    
    /// Get biometry type available on device
    private static func getBiometryType() -> String {
        guard #available(iOS 11, *) else { return "none" }
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "none"
        }
        
        if #available(iOS 13, *) {
            switch context.biometryType {
            case .faceID:
                return "faceID"
            case .touchID:
                return "touchID"
            case .opticID:
                return "opticID"
            @unknown default:
                return "biometric"
            }
        } else {
            // iOS 11-12 only have Touch ID
            return "touchID"
        }
    }
    
    /// Check if device has biometry available
    private static func isBiometryAvailable() -> Bool {
        guard #available(iOS 11, *) else { return false }
        
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Check if device has notch or dynamic island
    private static func hasNotchOrDynamicIsland() -> Bool {
        guard #available(iOS 11.0, *) else { return false }
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let window = window else { return false }
        return window.safeAreaInsets.top > 20
    }
    
    /// Get safe area insets
    private static func getSafeAreaInsets() -> [String: Int] {
        guard #available(iOS 11.0, *) else {
            return ["top": 0, "bottom": 0, "left": 0, "right": 0]
        }
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let window = window else {
            return ["top": 0, "bottom": 0, "left": 0, "right": 0]
        }
        
        let insets = window.safeAreaInsets
        return [
            "top": Int(insets.top),
            "bottom": Int(insets.bottom),
            "left": Int(insets.left),
            "right": Int(insets.right)
        ]
    }
    
    /// Check if device is in dark mode
    static func isDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                return false
            }
            return window.traitCollection.userInterfaceStyle == .dark
        }
        return false
    }
    
    /// Get network connectivity status
    static func getNetworkStatus() -> String {
        // This would typically use Network framework (iOS 12+) or Reachability
        // For now, return a placeholder
        return "connected"
    }
}
