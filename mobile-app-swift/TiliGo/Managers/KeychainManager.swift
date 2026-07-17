import Foundation
import Security

/// Manages secure storage using iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.tiligo.app"
    private let group = "com.tiligo.app.keychain"
    
    private init() {}
    
    // MARK: - Store
    
    /// Store a value securely in Keychain
    @discardableResult
    func store(value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return store(data: data, forKey: key)
    }
    
    /// Store data securely in Keychain
    @discardableResult
    func store(data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete existing value first
        SecItemDelete(query as CFDictionary)
        
        // Add new value
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Retrieve
    
    /// Retrieve a string value from Keychain
    func retrieve(forKey key: String) -> String? {
        guard let data = retrieveData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Retrieve data from Keychain
    func retrieveData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    // MARK: - Update
    
    /// Update an existing Keychain value
    @discardableResult
    func update(value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return update(data: data, forKey: key)
    }
    
    /// Update existing data in Keychain
    @discardableResult
    func update(data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Delete
    
    /// Delete a value from Keychain
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Delete all values for this service
    @discardableResult
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Existence Check
    
    /// Check if a value exists in Keychain
    func exists(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Common Use Cases
    
    /// Store authentication token
    @discardableResult
    func storeAuthToken(_ token: String) -> Bool {
        return store(value: token, forKey: "authToken")
    }
    
    /// Retrieve authentication token
    func getAuthToken() -> String? {
        return retrieve(forKey: "authToken")
    }
    
    /// Store refresh token
    @discardableResult
    func storeRefreshToken(_ token: String) -> Bool {
        return store(value: token, forKey: "refreshToken")
    }
    
    /// Retrieve refresh token
    func getRefreshToken() -> String? {
        return retrieve(forKey: "refreshToken")
    }
    
    /// Clear all authentication credentials
    @discardableResult
    func clearAuthCredentials() -> Bool {
        let deleted1 = delete(forKey: "authToken")
        let deleted2 = delete(forKey: "refreshToken")
        return deleted1 && deleted2
    }
}
