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
    private static let defaultLemmy: String = "lemmy.world" // TODO: Maybe that should be changeable when in guest-mode?
    private static let currentSessionKey: String = "LeomardApp"
    private static let allSessionsKey: String = "LeomardAppSessions"
   
    private var currentSession: SessionInfo? = nil
    private var sessions: [SessionInfo] = []
    
    private static let instance = SessionStorage()
    public static let getInstance = instance
    
    private init() {
        self.currentSession = self.load()
        self.sessions = self.loadAll()
    }
    
    /// Saves the current sesssion into sessions storage.
    public func save(response: SessionInfo) -> Bool {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(response) else {
            return false
        }
        
        // Remove the existing one first.
        _ = self.destroy()
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.currentSessionKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationContext as String: self.contextBuilder()
        ]
        
        let status = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        
        self.currentSession = response
        
        let addedToAll = self.addToAll(session: self.currentSession!)
        
        return status == errSecSuccess && addedToAll
    }
    
    /// Loads the current session
    public func load() -> SessionInfo? {
        if self.currentSession != nil {
            return self.currentSession
        }
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.currentSessionKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: self.contextBuilder()
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
    
    public func destroy() -> Bool {
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.currentSessionKey
        ]
        
        let status = SecItemDelete(keychainItemQuery as CFDictionary)
        self.currentSession = nil
        return status == errSecSuccess
    }
    
    public func addToAll(session: SessionInfo) -> Bool {
        if self.sessions.count > 0 {
            let containsSession = self.sessions.contains { stored in
                return stored == session
            }
            if containsSession {
                // Sessions array already has this session? Do not add it to the array.
                return true
            }
        }
        
        sessions.append(session)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(sessions) else {
            return false
        }
        
        // Before executing, we must delete the existing key.
        _ = self.deleteAll()
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.allSessionsKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationContext as String: self.contextBuilder()
        ]
        
        let status = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func loadAll() -> [SessionInfo] {
        if self.sessions.count > 0 {
            return self.sessions
        }
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.allSessionsKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: self.contextBuilder()
        ]
        
        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(keychainItemQuery as CFDictionary, &retrievedData)
        
        if status == errSecSuccess {
            if let data = retrievedData as? Data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try! decoder.decode([SessionInfo].self, from: data)
            }
        }
        
        return []
    }
    
    /// Removes the session from all sessions.
    public func remove(session: SessionInfo) -> Bool {
        if self.sessions.count == 0 {
            // Nothing to delete!
            return true
        }
        
        let containsSession = self.sessions.contains { stored in
            return stored == session
        }
        if !containsSession {
            // Session is not in stored. Nothing to remove.
            return true
        }
        
        sessions = sessions.filter { $0 != session }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(sessions) else {
            return false
        }
        
        // Before executing, we must delete the existing key.
        _ = self.deleteAll()
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.allSessionsKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationContext as String: self.contextBuilder()
        ]
        
        let status = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Removes all stored sessions.
    public func deleteAll() -> Bool {
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.allSessionsKey
        ]
        
        let status = SecItemDelete(keychainItemQuery as CFDictionary)
        self.currentSession = nil
        return status == errSecSuccess
    }
    
    public func isSessionActive() -> Bool {
        return self.currentSession != nil
    }
    
    public func getLemmyInstance() -> String {
        if self.currentSession == nil {
            return SessionStorage.defaultLemmy
        }
        
        return self.currentSession!.lemmyInstance
    }
    
    private func contextBuilder() -> LAContext {
        let context = LAContext()
        context.interactionNotAllowed = true
        return context
    }
}
