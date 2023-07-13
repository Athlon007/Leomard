//
//  SessionStorage.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import Security
import LocalAuthentication

class SessionStorage {
    private static var sessionKey = "key"
    private static let defaultLemmy = "lemmy.world"
    private static let root = "Leomard"
    private static let loginResponseFile = "LoginResponse.json"
    
    var currentSession: SessionInfo? = nil
    
    private static var instance = SessionStorage()
    public static var getInstance = instance
    
    private init() {
        self.currentSession = self.load()
    }
    
    private func getUrl(file: String) throws -> URL {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let output = supportDirectory.appendingPathComponent("\(SessionStorage.root)/\(file)")

        try fileManager.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        return output
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
            kSecAttrAccount as String: "LeomardApp",
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
            kSecAttrAccount as String: "LeomardApp",
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
            kSecAttrAccount as String: "LeomardApp"
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
