import Foundation
import LocalAuthentication

/// Manages biometric authentication (Face ID / Touch ID)
class BiometricManager {
    static let shared = BiometricManager()
    
    private let authContext = LAContext()
    
    private init() {}
    
    // MARK: - Biometry Availability
    
    /// Check if biometry is available on device
    func isBiometryAvailable() -> Bool {
        var error: NSError?
        return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Get the type of biometry available
    func getBiometryType() -> BiometryType {
        guard #available(iOS 11, *) else { return .none }
        
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        if #available(iOS 13, *) {
            switch authContext.biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            case .opticID:
                return .opticID
            @unknown default:
                return .unknown
            }
        } else {
            return .touchID
        }
    }
    
    /// Check if device has passcode/biometry set up
    func isDeviceSecured() -> Bool {
        var error: NSError?
        return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) ||
               authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    // MARK: - Authentication
    
    /// Authenticate user with biometry
    func authenticateUser(reason: String = "Authenticate to continue", completion: @escaping (Bool, String?) -> Void) {
        guard isBiometryAvailable() else {
            completion(false, "Biometry not available on this device")
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let errorMessage = error?.localizedDescription ?? "Biometry not available"
            completion(false, errorMessage)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                              localizedReason: reason) { success, evaluateError in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    let errorMessage = self.getErrorMessage(evaluateError as? LAError)
                    completion(false, errorMessage)
                }
            }
        }
    }
    
    /// Authenticate with biometry or passcode fallback
    func authenticateWithFallback(reason: String = "Authenticate to continue", completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false, "Device authentication not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication,
                              localizedReason: reason) { success, evaluateError in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    let errorMessage = self.getErrorMessage(evaluateError as? LAError)
                    completion(false, errorMessage)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func getErrorMessage(_ error: LAError?) -> String {
        guard let error = error else { return "Authentication failed" }
        
        switch error.code {
        case .authenticationFailed:
            return "Authentication failed. Try again."
        case .userCancel:
            return "Authentication cancelled by user"
        case .userFallback:
            return "User selected fallback method"
        case .systemCancel:
            return "Authentication cancelled by system"
        case .passcodeNotSet:
            return "No passcode set on device"
        case .biometryNotAvailable:
            return "Biometry not available"
        case .biometryNotEnrolled:
            return "Biometry not enrolled"
        case .biometryLockout:
            return "Too many failed attempts. Please try again later."
        case .notInteractive:
            return "Authentication requires interaction"
        @unknown default:
            return error.localizedDescription
        }
    }
}

// MARK: - Biometry Type Enum

enum BiometryType: String {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case opticID = "Optic ID"
    case none = "None"
    case unknown = "Unknown"
}
