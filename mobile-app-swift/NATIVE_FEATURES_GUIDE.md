# TiliGo Native Swift Features Implementation Guide

## Overview

This guide explains the native Swift features that have been implemented for the TiliGo iOS app. The implementation provides a bidirectional communication bridge between the native Swift code and the web app running in WKWebView.

## Architecture

### Core Components

1. **NativeBridge.swift** - Main bridge managing JavaScript ↔ Swift communication
2. **PermissionManager.swift** - Handles all permission requests (Camera, Location, Notifications, etc.)
3. **DeviceInfo.swift** - Provides device information to web app
4. **NotificationManager.swift** - Manages local and push notifications
5. **BiometricManager.swift** - Handles Face ID / Touch ID authentication
6. **KeychainManager.swift** - Secure storage using iOS Keychain
7. **DeepLinkHandler.swift** - Processes URL scheme deep links
8. **NativeBridge.js** - JavaScript bridge interface for web app

### Communication Flow

```
Web App (JavaScript) 
    ↓ (webkit.messageHandlers)
    ↑ (evaluateJavaScript)
Native Bridge (Swift)
    ↓ (PermissionManager, NotificationManager, etc.)
    ↑ (responses sent back to JavaScript)
```

## Features Implemented

### 1. JavaScript Bridge

**Files:** `NativeBridge.swift`, `NativeBridge.js`

The bridge enables bidirectional communication between JavaScript and Swift:

#### From JavaScript to Swift:
```javascript
// Request camera permission
const granted = await window.NativeMessage.call('requestCameraPermission', {});

// Show notification
await window.NativeMessage.showNotification('Order Ready', 'Your order #123 is ready');

// Get device info
const deviceInfo = await window.NativeMessage.getDeviceInfo();
```

#### From Swift to JavaScript:
```swift
nativeBridge.sendMessage(method: "onDeepLink", data: deepLinkData)
nativeBridge.sendResponse(id: "123", data: ["granted": true])
nativeBridge.sendError(id: "123", message: "Permission denied")
```

### 2. Permission Management

**File:** `PermissionManager.swift`

Handles requests for:
- Camera
- Location (always and when in use)
- Notifications (push notifications)
- Microphone
- Photo Library
- Contacts

**Usage:**
```javascript
// Request camera permission from web app
const granted = await window.NativeMessage.requestCameraPermission();

// Request location permission
const hasLocation = await window.NativeMessage.requestLocationPermission();
```

### 3. Device Information

**File:** `DeviceInfo.swift`

Provides comprehensive device information:
```javascript
const info = await window.NativeMessage.getDeviceInfo();
// Returns: {
//   platform: "iOS",
//   osVersion: "17.0",
//   appVersion: { version: "1.0", build: "1" },
//   deviceModel: "iPhone",
//   deviceName: "John's iPhone",
//   screenSize: { width: 390, height: 844, scale: 3, nativeScale: 3 },
//   locale: "en_US",
//   timezone: "America/New_York",
//   biometryType: "faceID",
//   biometryAvailable: true,
//   hasNotchOrDynamicIsland: true,
//   safeAreaInsets: { top: 59, bottom: 34, left: 0, right: 0 }
// }
```

### 4. Notifications

**File:** `NotificationManager.swift`

#### Local Notifications:
```swift
NotificationManager.shared.showLocalNotification(
    title: "Delivery Update",
    body: "Your order is nearby",
    delay: 2,
    completion: { success in print(success) }
)
```

#### Push Notifications:
- Handled in `AppDelegate`
- Registers for remote notifications
- Processes notification payloads
- Supports deep links in notifications

### 5. Biometric Authentication

**File:** `BiometricManager.swift`

#### Face ID / Touch ID:
```javascript
// From web app
const authenticated = await window.NativeMessage.authenticateBiometric();

// From Swift
BiometricManager.shared.authenticateUser { success, error in
    if success {
        // User authenticated
    }
}
```

**Features:**
- Detects available biometry type (Face ID, Touch ID, Optic ID)
- Handles authentication with user-friendly error messages
- Supports fallback to device passcode

### 6. Secure Storage (Keychain)

**File:** `KeychainManager.swift`

#### From JavaScript:
```javascript
// Store auth token securely
await window.NativeMessage.storeSecurely('authToken', token);

// Retrieve auth token
const token = await window.NativeMessage.retrieveSecure('authToken');
```

#### From Swift:
```swift
KeychainManager.shared.storeAuthToken("token_123")
let token = KeychainManager.shared.getAuthToken()
```

**Security Features:**
- Encrypted storage
- Access level: `kSecAttrAccessibleWhenUnlocked`
- Automatic cleanup methods
- Token management helpers

### 7. Deep Linking

**Files:** `DeepLinkHandler.swift`, `AppDelegate.swift`

#### URL Scheme Format:
```
tiligo://[path]?param1=value1&param2=value2
```

#### Examples:
```
tiligo://order?id=123
tiligo://delivery?id=456
tiligo://chat?user=user_789
tiligo://profile?id=user_abc
```

#### Usage:
```javascript
// Listen for deep links
window.addEventListener('deepLink', (event) => {
    const { path, params, screen } = event.detail;
    console.log('Deep link:', screen, params);
    // Navigate app based on screen
});
```

#### From Swift:
```swift
// Generate deep link
let url = DeepLinkHandler.createOrderLink(orderId: "123")

// Open deep link from notification
if let url = URL(string: "tiligo://order?id=123") {
    UIApplication.shared.open(url)
}
```

## Setup Instructions

### 1. Info.plist Configuration

✅ **Already configured** with:
- Camera usage description
- Location usage descriptions
- Photo library access descriptions
- Microphone usage description
- Contacts access description
- URL scheme registration (tiligo://)
- Local network usage description

### 2. Inject JavaScript Bridge into Web App

Add this to your web app's HTML `<head>`:

```html
<script src="path/to/NativeBridge.js"></script>
```

Or manually add the bridge code before loading your app.

### 3. Request Notification Permissions

In your web app:
```javascript
// Request notification permission from user
const granted = await PermissionManager.shared.requestNotificationPermission();
```

### 4. Enable Remote Notifications in Xcode

1. Open Xcode project
2. Select TiliGo target
3. Go to Signing & Capabilities
4. Click "+ Capability"
5. Add "Push Notifications"

### 5. Register APNs Certificate

1. Go to Apple Developer Portal
2. Create APNs certificate (SSL)
3. Download and install in Keychain
4. Export and upload to your notification service

## Usage Examples

### Example 1: Request Camera Permission

```javascript
// In your web app
async function takeCameraPhoto() {
    const hasPermission = await window.NativeMessage.requestCameraPermission();
    
    if (hasPermission) {
        // Show camera picker
        // Implementation depends on your web app architecture
    } else {
        // Show "Camera permission denied" message
    }
}
```

### Example 2: Store User Token

```javascript
// After successful login
const token = response.data.authToken;
const stored = await window.NativeMessage.storeSecurely('authToken', token);

// Later, retrieve on app launch
const savedToken = await window.NativeMessage.retrieveSecure('authToken');
if (savedToken) {
    // Auto-login user
}
```

### Example 3: Deep Link Navigation

```javascript
// Listen for deep links
window.addEventListener('deepLink', async (event) => {
    const { screen, params } = event.detail;
    
    switch (screen) {
        case 'order':
            navigateToOrderDetails(params.id);
            break;
        case 'delivery':
            navigateToDeliveryTracking(params.id);
            break;
        case 'chat':
            openChatWith(params.user);
            break;
        default:
            navigateTo(screen);
    }
});
```

### Example 4: Show Notifications

```javascript
// When delivery arrives
await window.NativeMessage.showNotification(
    'Delivery Arrived',
    'Your order #123 has arrived. Click to view details.'
);
```

### Example 5: Biometric Authentication

```javascript
// For sensitive operations like payment
const authenticated = await window.NativeMessage.authenticateBiometric();

if (authenticated) {
    // Proceed with payment
    processPayment();
} else {
    // Show error
    showError('Authentication failed');
}
```

## Testing

### Test on Physical Device

1. Connect iPhone to Mac
2. Open TiliGo.xcodeproj in Xcode
3. Select your device in the scheme dropdown
4. Click "Run" (Cmd + R)

### Test Deep Links

```swift
// In Xcode console
xcrun simctl openurl booted "tiligo://order?id=123"
```

Or on physical device:
```
Preferences > Developer > URL schemes
```

### Test Notifications

Use Apple's push notification testing:
```bash
xcrun simctl push booted com.tiligo.app '{"aps":{"alert":"Test notification"}}'
```

## File Structure

```
mobile-app-swift/TiliGo/
├── AppDelegate.swift                  # ✅ Updated: Deep linking, notifications
├── ViewController.swift               # ✅ Updated: JS bridge registration
├── Info.plist                         # ✅ Updated: Permissions, URL scheme
│
├── Managers/                          # ✅ New Directory
│   ├── NativeBridge.swift             # ✅ JS ↔ Swift communication
│   ├── PermissionManager.swift        # ✅ Permission requests
│   ├── DeviceInfo.swift               # ✅ Device information
│   ├── NotificationManager.swift      # ✅ Local/push notifications
│   ├── BiometricManager.swift         # ✅ Face ID / Touch ID
│   ├── KeychainManager.swift          # ✅ Secure storage
│   ├── DeepLinkHandler.swift          # ✅ URL scheme routing
│   └── NativeBridge.js                # ✅ JavaScript interface
```

## Next Steps (Phase 3+)

### Phase 3: Advanced Permissions
- [ ] Implement location tracking in background
- [ ] Handle location permission state changes
- [ ] Create location service for real-time tracking

### Phase 4: Push Notifications
- [ ] Set up APNs server
- [ ] Implement token refresh logic
- [ ] Create notification handling UI

### Phase 5: Camera & Media
- [ ] Implement camera picker UI
- [ ] Add photo library integration
- [ ] Handle image compression/upload

### Phase 6: Advanced Features
- [ ] Background tasks
- [ ] Local data caching
- [ ] Offline support

## Troubleshooting

### Build Errors

**"NativeBridge not found"**
- Ensure all files in Managers/ are added to TiliGo target
- Check Build Phases > Compile Sources

**"WKScriptMessageHandler not responding"**
- Verify userContentController setup in NativeBridge init
- Check that JavaScript is evaluating after page load

### Runtime Issues

**Permissions not being requested**
- Verify Info.plist has appropriate usage descriptions
- Check Privacy > Microphone (Settings > Privacy) on device

**Notifications not showing**
- Confirm APNs certificate is properly configured
- Check notification permissions in Settings > Notifications
- Verify device token is being sent to server

**Deep links not working**
- Test with: `xcrun simctl openurl booted "tiligo://order?id=123"`
- Verify URL scheme in Info.plist matches handler
- Check AppDelegate URL handling implementation

## Security Considerations

✅ **Implemented:**
- Keychain encryption for sensitive data
- HTTPS for web communication (set in Info.plist)
- Permission prompts for user privacy
- Biometric authentication support

⚠️ **Additional Recommendations:**
- Never store authentication tokens in UserDefaults
- Validate all deep link URLs before processing
- Implement certificate pinning for API calls
- Use secure, random IDs for notifications
- Implement token refresh logic for expired tokens

## Performance Notes

- **Memory:** NativeBridge uses weak references to prevent memory leaks
- **Network:** Keychain operations are synchronous (use dispatch_async if needed)
- **Notifications:** Throttle notification requests to prevent spam
- **Biometric:** Timeout is set to 30 seconds per API request

## Support & Documentation

- [Apple WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [LocalAuthentication Framework](https://developer.apple.com/documentation/localauthentication)
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Push Notifications](https://developer.apple.com/notifications/)
- [Universal Links & URL Schemes](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_communicate)

---

**Implementation Date:** July 2026  
**Swift Version:** 5.9+  
**iOS Deployment Target:** 12.0+  
**Status:** ✅ Phase 1-2 Complete (JavaScript Bridge & Permissions)
