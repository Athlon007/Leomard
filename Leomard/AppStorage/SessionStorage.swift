//
//  SessionStorage.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import Security
import LocalAuthentication

final class SessionStorage {
    private static var sessionKey = "key"
    private static let defaultLemmy = "lemmy.world"
    private static let root = "LeomardApp"
    
    private var currentSession: SessionInfo? = nil
    
    private static let instance = SessionStorage()
    public static let getInstance = instance
    
    private init() {
        self.currentSession = self.load()
    }
    
    public func save(response: SessionInfo) -> Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(response) else {
            return false
        }
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.root,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationContext as String: context
        ]
        
        let status = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        
        self.currentSession = response
        
        return status == errSecSuccess
    }
    
    public func load() -> SessionInfo? {
        if self.currentSession != nil {
            return self.currentSession
        }
        
        let context = LAContext()
        context.interactionNotAllowed = true
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.root,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]
        
        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(keychainItemQuery as CFDictionary, &retrievedData)
        
        if status == errSecSuccess {
            if let data = retrievedData as? Data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try? decoder.decode(SessionInfo.self, from: data)
            }
        }
        
        return nil
    }
    
    public func isSessionActive() -> Bool {
        return self.currentSession != nil
    }
    
    public func destroy() -> Bool {
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.root
        ]
        
        let status = SecItemDelete(keychainItemQuery as CFDictionary)
        self.currentSession = nil
        return status == errSecSuccess
    }
    
    public func getLemmyInstance() -> String {
        if self.currentSession == nil {
            return SessionStorage.defaultLemmy
        }
        
        return self.currentSession!.lemmyInstance
    }
}
