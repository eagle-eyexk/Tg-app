import Foundation
import WebKit

/// Manages bidirectional communication between Swift native code and JavaScript web app
class NativeBridge {
    weak var webView: WKWebView?
    private var handlers: [String: (Any) -> Void] = [:]
    
    init(webView: WKWebView) {
        self.webView = webView
        setupMessageHandlers()
    }
    
    // MARK: - Message Handler Setup
    
    private func setupMessageHandlers() {
        // Register all native message handlers from JavaScript
        let handlerNames = [
            "requestCameraPermission",
            "requestLocationPermission",
            "showNativeNotification",
            "getDeviceInfo",
            "requestBiometric",
            "openCamera",
            "requestPhotoLibrary",
            "storeSecurely",
            "retrieveSecure"
        ]
        
        for handlerName in handlerNames {
            webView?.configuration.userContentController.add(self, name: handlerName)
        }
    }
    
    // MARK: - Message Sending (Swift to JavaScript)
    
    /// Send a message from Swift to JavaScript
    /// - Parameters:
    ///   - method: The JavaScript method name to call
    ///   - data: Dictionary of data to pass (will be JSON encoded)
    func sendMessage(method: String, data: [String: Any]? = nil) {
        guard let webView = webView else { return }
        
        var script = "window.NativeMessage?.handleNativeMessage('\(method)'"
        
        if let data = data {
            if let jsonData = try? JSONSerialization.data(withJSONObject: data),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                script += ", \(jsonString)"
            }
        }
        
        script += ");"
        
        DispatchQueue.main.async {
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("[NativeBridge] Error sending message: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Response Handling
    
    /// Send a success response back to JavaScript
    func sendResponse(id: String, data: [String: Any]? = nil) {
        var response: [String: Any] = ["success": true, "id": id]
        if let data = data {
            response["data"] = data
        }
        sendMessage(method: "onNativeResponse", data: response)
    }
    
    /// Send an error response back to JavaScript
    func sendError(id: String, message: String) {
        let error: [String: Any] = [
            "success": false,
            "id": id,
            "error": message
        ]
        sendMessage(method: "onNativeError", data: error)
    }
    
    // MARK: - Utility Methods
    
    /// Register a custom handler for a specific message
    func registerHandler(_ name: String, handler: @escaping (Any) -> Void) {
        handlers[name] = handler
    }
    
    /// Decode JSON message body
    static func decodeMessage(_ body: Any) -> [String: Any]? {
        if let dict = body as? [String: Any] {
            return dict
        } else if let jsonString = body as? String,
                  let data = jsonString.data(using: .utf8),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return dict
        }
        return nil
    }
}

// MARK: - WKScriptMessageHandler

extension NativeBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
        let handlerName = message.name
        let body = message.body
        
        print("[NativeBridge] Received message: \(handlerName)")
        
        // Decode the message body
        guard let messageData = Self.decodeMessage(body) else {
            print("[NativeBridge] Failed to decode message body")
            return
        }
        
        // Execute the appropriate handler
        switch handlerName {
        case "requestCameraPermission":
            handleCameraPermissionRequest(messageData)
        case "requestLocationPermission":
            handleLocationPermissionRequest(messageData)
        case "showNativeNotification":
            handleShowNotification(messageData)
        case "getDeviceInfo":
            handleGetDeviceInfo(messageData)
        case "requestBiometric":
            handleBiometricRequest(messageData)
        case "openCamera":
            handleOpenCamera(messageData)
        case "requestPhotoLibrary":
            handlePhotoLibraryRequest(messageData)
        case "storeSecurely":
            handleStoreSecurely(messageData)
        case "retrieveSecure":
            handleRetrieveSecure(messageData)
        default:
            if let handler = handlers[handlerName] {
                handler(messageData)
            }
        }
    }
    
    // MARK: - Handler Methods
    
    private func handleCameraPermissionRequest(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        PermissionManager.shared.requestCameraPermission { granted in
            self.sendResponse(id: id, data: ["granted": granted])
        }
    }
    
    private func handleLocationPermissionRequest(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        PermissionManager.shared.requestLocationPermission { granted in
            self.sendResponse(id: id, data: ["granted": granted])
        }
    }
    
    private func handleShowNotification(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        let title = data["title"] as? String ?? ""
        let message = data["message"] as? String ?? ""
        
        NotificationManager.shared.showLocalNotification(title: title, body: message) { success in
            self.sendResponse(id: id, data: ["success": success])
        }
    }
    
    private func handleGetDeviceInfo(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        let deviceInfo = DeviceInfo.getDeviceInfo()
        sendResponse(id: id, data: deviceInfo)
    }
    
    private func handleBiometricRequest(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        BiometricManager.shared.authenticateUser { success, error in
            if success {
                self.sendResponse(id: id, data: ["authenticated": true])
            } else {
                self.sendError(id: id, message: error ?? "Biometric authentication failed")
            }
        }
    }
    
    private func handleOpenCamera(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        // This would typically be handled by presenting a camera view controller
        // For now, send a placeholder response
        sendError(id: id, message: "Camera feature not yet implemented")
    }
    
    private func handlePhotoLibraryRequest(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        // This would typically present a photo picker
        // For now, send a placeholder response
        sendError(id: id, message: "Photo library feature not yet implemented")
    }
    
    private func handleStoreSecurely(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        guard let key = data["key"] as? String,
              let value = data["value"] as? String else {
            sendError(id: id, message: "Invalid parameters")
            return
        }
        
        let success = KeychainManager.shared.store(value: value, forKey: key)
        sendResponse(id: id, data: ["success": success])
    }
    
    private func handleRetrieveSecure(_ data: [String: Any]) {
        let id = data["id"] as? String ?? "unknown"
        guard let key = data["key"] as? String else {
            sendError(id: id, message: "Invalid key")
            return
        }
        
        if let value = KeychainManager.shared.retrieve(forKey: key) {
            sendResponse(id: id, data: ["value": value])
        } else {
            sendError(id: id, message: "Value not found")
        }
    }
}
