# TiliGo Native Swift Features - Quick Reference

## 🎯 Quick Links

- **Full Guide:** [`NATIVE_FEATURES_GUIDE.md`](mobile-app-swift/NATIVE_FEATURES_GUIDE.md)
- **Implementation Summary:** [`NATIVE_SWIFT_IMPLEMENTATION_SUMMARY.md`](NATIVE_SWIFT_IMPLEMENTATION_SUMMARY.md)
- **Source Code:** [`mobile-app-swift/TiliGo/Managers/`](mobile-app-swift/TiliGo/Managers/)

---

## 📖 JavaScript API Cheat Sheet

### Permissions

```javascript
// Camera
const granted = await window.NativeMessage.requestCameraPermission();

// Location
const hasLocation = await window.NativeMessage.requestLocationPermission();

// Biometric (Face ID/Touch ID)
const authenticated = await window.NativeMessage.authenticateBiometric();
```

### Notifications

```javascript
// Show local notification
await window.NativeMessage.showNotification(
    'Title',
    'Message body'
);

// Listen to received notifications
window.addEventListener('nativeMessage', (e) => {
    console.log(e.detail);
});
```

### Device Info

```javascript
// Get all device info
const info = await window.NativeMessage.getDeviceInfo();

// Access properties
console.log(info.platform);        // "iOS"
console.log(info.osVersion);       // "17.0"
console.log(info.deviceModel);     // "iPhone"
console.log(info.biometryType);    // "faceID", "touchID", or "none"
console.log(info.screenSize);      // { width, height, scale, nativeScale }
```

### Secure Storage

```javascript
// Store auth token
await window.NativeMessage.storeSecurely('authToken', token);

// Retrieve auth token
const token = await window.NativeMessage.retrieveSecure('authToken');

// Common use: Auto-login on app launch
const savedToken = await window.NativeMessage.retrieveSecure('authToken');
if (savedToken) {
    // Auto-login with token
}
```

### Deep Links

```javascript
// Listen for deep links
window.addEventListener('deepLink', (event) => {
    const { screen, path, params } = event.detail;
    
    switch(screen) {
        case 'order':
            showOrderDetails(params.id);
            break;
        case 'delivery':
            showDeliveryTracking(params.id);
            break;
    }
});
```

### Error Handling

```javascript
try {
    const granted = await window.NativeMessage.requestCameraPermission();
} catch (error) {
    console.error('Permission error:', error.message);
}
```

---

## 🔧 Swift API Cheat Sheet

### NativeBridge

```swift
// Initialize
let bridge = NativeBridge(webView: webView)

// Send message to JavaScript
bridge.sendMessage(method: "onOrderUpdate", data: [
    "orderId": "123",
    "status": "delivered"
])

// Send response
bridge.sendResponse(id: "msg-id", data: ["success": true])

// Send error
bridge.sendError(id: "msg-id", message: "Something failed")
```

### PermissionManager

```swift
// Request camera
PermissionManager.shared.requestCameraPermission { granted in
    print("Camera: \(granted)")
}

// Check camera status
let status = PermissionManager.shared.cameraPermissionStatus()

// Request location
PermissionManager.shared.requestLocationPermission { granted in
    print("Location: \(granted)")
}

// Request notifications
PermissionManager.shared.requestNotificationPermission { granted in
    print("Notifications: \(granted)")
}
```

### NotificationManager

```swift
// Show local notification
NotificationManager.shared.showLocalNotification(
    title: "Order Ready",
    body: "Your order #123 is ready",
    delay: 2
) { success in
    print("Notification: \(success)")
}

// Set badge
NotificationManager.shared.setAppBadge(5)

// Clear badge
NotificationManager.shared.clearAppBadge()

// Register for remote notifications
NotificationManager.shared.registerForRemoteNotifications()
```

### KeychainManager

```swift
// Store token
KeychainManager.shared.storeAuthToken("token_abc123")

// Retrieve token
if let token = KeychainManager.shared.getAuthToken() {
    print("Token: \(token)")
}

// Store custom value
KeychainManager.shared.store(value: "secret", forKey: "myKey")

// Retrieve custom value
if let value = KeychainManager.shared.retrieve(forKey: "myKey") {
    print("Value: \(value)")
}

// Clear credentials
KeychainManager.shared.clearAuthCredentials()
```

### BiometricManager

```swift
// Check if biometry available
if BiometricManager.shared.isBiometryAvailable() {
    print("Biometry available")
}

// Get biometry type
let type = BiometricManager.shared.getBiometryType()
// Returns: .faceID, .touchID, .opticID, or .none

// Authenticate user
BiometricManager.shared.authenticateUser { success, error in
    if success {
        print("Authenticated!")
    } else {
        print("Error: \(error ?? "Unknown")")
    }
}

// Authenticate with fallback to passcode
BiometricManager.shared.authenticateWithFallback { success, error in
    print("Auth result: \(success)")
}
```

### DeepLinkHandler

```swift
// Handle deep link
deepLinkHandler.handle(url: url)

// Generate deep link
let url = DeepLinkHandler.createOrderLink(orderId: "123")
UIApplication.shared.open(url)

// Other deep link generators
DeepLinkHandler.createDeliveryLink(deliveryId: "456")
DeepLinkHandler.createChatLink(withUserId: "user_789")
DeepLinkHandler.createProfileLink(userId: "user_abc")
```

### DeviceInfo

```swift
// Get all device info
let info = DeviceInfo.getDeviceInfo()

// Use specific info
let osVersion = info["osVersion"]
let isDarkMode = DeviceInfo.isDarkMode()
let networkStatus = DeviceInfo.getNetworkStatus()
```

---

## 🌐 Deep Link Examples

### Open Orders
```
tiligo://order?id=123
tiligo://order?id=123&action=track
```

### Delivery Tracking
```
tiligo://delivery?id=456
tiligo://delivery?id=456&highlight_map=true
```

### Chat
```
tiligo://chat?user=user_789
tiligo://chat?user=user_789&message=Hello
```

### Profile
```
tiligo://profile              # Current user
tiligo://profile?id=user_abc  # Other user
```

---

## 🔑 Initialization (In Your App)

### AppDelegate.swift
```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Setup notifications
    NotificationManager.shared.setupNotifications()
    
    // Handle launch deep links
    if let notif = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
        // Process notification
    }
    
    return true
}

// Handle URL schemes
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if let viewController = window?.rootViewController as? ViewController {
        viewController.handleDeepLink(url: url)
    }
    return true
}
```

### ViewController.swift
```swift
class ViewController: UIViewController {
    private var nativeBridge: NativeBridge?
    private var deepLinkHandler: DeepLinkHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNativeBridge()
    }
    
    private func setupNativeBridge() {
        nativeBridge = NativeBridge(webView: webView)
        deepLinkHandler = DeepLinkHandler(nativeBridge: nativeBridge)
    }
    
    func handleDeepLink(url: URL) {
        deepLinkHandler?.handle(url: url)
    }
}
```

---

## ✅ Checklist for Integration

### Web App Setup
- [ ] Add `NativeBridge.js` to your HTML
- [ ] Listen for `nativeBridgeReady` event
- [ ] Test all permission requests
- [ ] Implement deep link listeners

### iOS Setup
- [ ] Verify all Manager files are in project
- [ ] Check Info.plist permissions are set
- [ ] Update AppDelegate.swift with handlers
- [ ] Update ViewController.swift with bridge
- [ ] Test on physical device

### Testing
- [ ] Build in Xcode (Cmd + B)
- [ ] Test camera permission
- [ ] Test location permission
- [ ] Test biometric auth
- [ ] Test notifications
- [ ] Test deep links: `tiligo://order?id=123`
- [ ] Test keychain storage

---

## 🐛 Common Issues

### "NativeBridge not found"
→ Ensure files are added to TiliGo target in Xcode
→ Check Build Phases > Compile Sources

### "Native method not available"
→ Verify `userContentController.add(self, name:)` is called in NativeBridge
→ Check message handler name matches

### "Permissions not requesting"
→ Verify Info.plist has usage descriptions
→ Check settings on device: Settings > Privacy

### "Deep links not working"
→ Test with: `xcrun simctl openurl booted "tiligo://order?id=123"`
→ Verify URL scheme in Info.plist

### "Keychain returns nil"
→ Check value was actually stored
→ Verify app has required entitlements

---

## 📚 Learning Resources

- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [LocalAuthentication Framework](https://developer.apple.com/documentation/localauthentication)
- [Security Framework (Keychain)](https://developer.apple.com/documentation/security/keychain_services)
- [UserNotifications](https://developer.apple.com/documentation/usernotifications)
- [CoreLocation](https://developer.apple.com/documentation/corelocation)

---

## 🚀 Next Steps

1. **Integrate into web app** - Add NativeBridge.js to your HTML
2. **Test permissions** - Verify all permission requests work
3. **Implement deep linking** - Listen to deepLink events
4. **Handle notifications** - Show alerts when notifications arrive
5. **Phase 3+** - Implement camera, location tracking, background tasks

---

## 📞 Support

- See full guide: [`NATIVE_FEATURES_GUIDE.md`](mobile-app-swift/NATIVE_FEATURES_GUIDE.md)
- Check examples: [`NATIVE_SWIFT_IMPLEMENTATION_SUMMARY.md`](NATIVE_SWIFT_IMPLEMENTATION_SUMMARY.md)
- View source: [`mobile-app-swift/TiliGo/Managers/`](mobile-app-swift/TiliGo/Managers/)

---

**Last Updated:** July 2026  
**Version:** 1.0 (Phase 1-2 Complete)  
**Status:** ✅ Production Ready
