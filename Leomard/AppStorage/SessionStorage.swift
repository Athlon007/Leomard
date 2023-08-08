//
//  SessionStorage.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import Security
import LocalAuthentication
import SwiftUI

final class SessionStorage {
    private static let defaultLemmy: String = "lemmy.world" // TODO: Maybe that should be changeable when in guest-mode?
    private static let key: String = "LeomardApp"
   
    private var sessions: Sessions
    
    private static let instance = SessionStorage()
    public static let getInstance = instance
    
    private init() {
        self.sessions = Sessions()
        self.sessions = load()
    }
    
    /// Updates the Keychain entry of Leomard.
    private func updateKeychain() -> Bool {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(sessions) else {
            return false
        }
        
        // Remove the existing one first.
        _ = self.deleteAll()
        
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationContext as String: self.contextBuilder()
        ]
        
        let status = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        
        self.sessions = self.load()
        
        return status == errSecSuccess
    }
    
    /// Saves the current sesssion into sessions storage.
    public func setCurrentSession(_ session: SessionInfo) -> Bool {
        sessions.currentSession = session
        
        let sessionStored = sessions.allSessions.contains { storedSession in
            session == storedSession
        }
        
        if !sessionStored {
            sessions.allSessions.append(session)
        }
        
        return self.updateKeychain()
    }
    
    public func updateCurrent(loginResponse: LoginResponse) -> Bool {
        if sessions.currentSession == nil {
            return false
        }
        
        var updated = sessions.currentSession!
        updated.loginResponse = loginResponse
        
        let index = sessions.allSessions.firstIndex(of: sessions.currentSession!)
        if index == nil {
            return false
        }
        
        sessions.allSessions[index!] = updated
        sessions.currentSession = updated
        
        return self.updateKeychain()
    }
    
    /// Returns the current session
    public func getCurrentSession() -> SessionInfo? {
        return self.sessions.currentSession
    }
    
    public func getAllSessions() -> [SessionInfo] {
        return self.sessions.allSessions
    }
    
    /// Ends the current session.
    public func endSession() -> Bool {
        sessions.currentSession = nil
        return updateKeychain()
    }
    
    public func load() -> Sessions {
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.key,
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
                let response = try? decoder.decode(Sessions.self, from: data)
                return response ?? Sessions()
            }
        }
        
        return Sessions()
    }
    
    /// Removes the session from all sessions.
    public func remove(session: SessionInfo) -> Bool {
        if sessions.allSessions.count == 0 {
            return true
        }
        
        if session == sessions.currentSession {
            sessions.currentSession = nil
        }
        
        sessions.allSessions = sessions.allSessions.filter { $0 != session }
        
        return updateKeychain()
    }
    
    /// Removes all stored sessions.
    public func deleteAll() -> Bool {
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SessionStorage.key
        ]
        
        let status = SecItemDelete(keychainItemQuery as CFDictionary)
        self.sessions = Sessions()
        return status == errSecSuccess
    }
    
    public func isSessionActive() -> Bool {
        return self.sessions.currentSession != nil
    }
    
    public func getLemmyInstance() -> String {
        return self.getCurrentSession()?.lemmyInstance ?? SessionStorage.defaultLemmy
    }
    
    private func contextBuilder() -> LAContext {
        let context = LAContext()
        context.interactionNotAllowed = true
        return context
    }
    
    public func addLikedPost(post: Post) -> Bool {
        if var updated = sessions.currentSession, !updated.likedPosts.contains(post.id) {
            updated.likedPosts.insert(post.id, at: 0)
            
            let index = sessions.allSessions.firstIndex(of: sessions.currentSession!)
            if index == nil {
                return false
            }
            
            sessions.allSessions[index!] = updated
            sessions.currentSession = updated
            
            return self.updateKeychain()
        }
        return false
    }
    
    public func removeLikedPost(post: Post) -> Bool {
        if var updated = sessions.currentSession, updated.likedPosts.contains(post.id) {
            updated.likedPosts = updated.likedPosts.filter { $0 != post.id }
            
            let index = sessions.allSessions.firstIndex(of: sessions.currentSession!)
            if index == nil {
                return false
            }
            
            sessions.allSessions[index!] = updated
            sessions.currentSession = updated
            
            return self.updateKeychain()
        }
        return false
    }
}
