import Foundation
import AVFoundation
import CoreLocation
import UserNotifications

/// Manages permission requests for various iOS features
class PermissionManager {
    static let shared = PermissionManager()
    private var locationManager: CLLocationManager?
    private var locationCompletion: ((Bool) -> Void)?
    
    private init() {}
    
    // MARK: - Camera Permission
    
    /// Request camera permission
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    /// Check current camera permission status
    func cameraPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    // MARK: - Location Permission
    
    /// Request location permission (always)
    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            setupLocationManager(completion: completion)
        @unknown default:
            completion(false)
        }
    }
    
    private func setupLocationManager(completion: @escaping (Bool) -> Void) {
        locationCompletion = completion
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAndWhenInUseAuthorization()
    }
    
    /// Check current location permission status
    func locationPermissionStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // MARK: - Notification Permission
    
    /// Request notification permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                completion(granted)
            }
        }
    }
    
    /// Check current notification permission status
    func notificationPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Microphone Permission
    
    /// Request microphone permission
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Photo Library Permission
    
    /// Request photo library permission
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        }
    }
    
    // MARK: - Contacts Permission
    
    /// Request contacts permission
    func requestContactsPermission(completion: @escaping (Bool) -> Void) {
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension PermissionManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationCompletion?(true)
        case .denied, .restricted:
            locationCompletion?(false)
        case .notDetermined:
            break
        @unknown default:
            locationCompletion?(false)
        }
        
        locationCompletion = nil
        locationManager?.delegate = nil
        locationManager = nil
    }
}

// Import Contacts framework
import Contacts
import Photos
