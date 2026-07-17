import Foundation

/// Handles deep link URL schemes and routes them to the web app
class DeepLinkHandler {
    weak var nativeBridge: NativeBridge?
    
    init(nativeBridge: NativeBridge? = nil) {
        self.nativeBridge = nativeBridge
    }
    
    // MARK: - URL Parsing
    
    /// Parse and handle a deep link URL
    func handle(url: URL) {
        guard url.scheme == "tiligo" else { return }
        
        let path = url.host ?? ""
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryParams = components?.queryItems ?? []
        
        print("[DeepLinkHandler] Handling deep link: \(url.absoluteString)")
        
        // Build the data dictionary to send to web app
        var data: [String: Any] = [
            "path": path,
            "url": url.absoluteString
        ]
        
        // Add query parameters
        if !queryParams.isEmpty {
            var params: [String: String] = [:]
            for item in queryParams {
                params[item.name] = item.value ?? ""
            }
            data["params"] = params
        }
        
        // Route to appropriate handler
        routeDeepLink(path: path, data: data)
    }
    
    // MARK: - Deep Link Routing
    
    private func routeDeepLink(path: String, data: [String: Any]) {
        switch path.lowercased() {
        case "order":
            handleOrderDeepLink(data)
        case "delivery":
            handleDeliveryDeepLink(data)
        case "profile":
            handleProfileDeepLink(data)
        case "chat":
            handleChatDeepLink(data)
        case "notification":
            handleNotificationDeepLink(data)
        default:
            handleGenericDeepLink(path, data: data)
        }
    }
    
    private func handleOrderDeepLink(_ data: [String: Any]) {
        var routeData = data
        routeData["screen"] = "order"
        sendToWebApp(routeData)
    }
    
    private func handleDeliveryDeepLink(_ data: [String: Any]) {
        var routeData = data
        routeData["screen"] = "delivery"
        sendToWebApp(routeData)
    }
    
    private func handleProfileDeepLink(_ data: [String: Any]) {
        var routeData = data
        routeData["screen"] = "profile"
        sendToWebApp(routeData)
    }
    
    private func handleChatDeepLink(_ data: [String: Any]) {
        var routeData = data
        routeData["screen"] = "chat"
        sendToWebApp(routeData)
    }
    
    private func handleNotificationDeepLink(_ data: [String: Any]) {
        var routeData = data
        routeData["screen"] = "notification"
        sendToWebApp(routeData)
    }
    
    private func handleGenericDeepLink(_ path: String, data: [String: Any]) {
        var routeData = data
        routeData["screen"] = path
        sendToWebApp(routeData)
    }
    
    // MARK: - Web App Communication
    
    private func sendToWebApp(_ data: [String: Any]) {
        nativeBridge?.sendMessage(method: "onDeepLink", data: data)
    }
    
    // MARK: - URL Scheme Examples
    
    /// Generate a deep link URL
    static func generateURL(path: String, params: [String: String] = [:]) -> URL? {
        var components = URLComponents()
        components.scheme = "tiligo"
        components.host = path
        
        if !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components.url
    }
    
    // MARK: - Common Deep Links
    
    /// Create order deep link
    static func createOrderLink(orderId: String) -> URL? {
        return generateURL(path: "order", params: ["id": orderId])
    }
    
    /// Create delivery tracking deep link
    static func createDeliveryLink(deliveryId: String) -> URL? {
        return generateURL(path: "delivery", params: ["id": deliveryId])
    }
    
    /// Create chat deep link
    static func createChatLink(withUserId userId: String) -> URL? {
        return generateURL(path: "chat", params: ["user": userId])
    }
    
    /// Create profile deep link
    static func createProfileLink(userId: String? = nil) -> URL? {
        var params: [String: String] = [:]
        if let userId = userId {
            params["id"] = userId
        }
        return generateURL(path: "profile", params: params)
    }
}
