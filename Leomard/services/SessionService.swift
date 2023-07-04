//
//  SessionService.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

class SessionService: Service {
    private static var sessionKey = "key"
    private var currentSession: SessionInfo? = nil
    private static let defaultLemmy = "lemmy.world"
    private static let root = "Leomard"
    private static let loginResponseFile = "LoginResponse.json"
    
    public override init() {
        super.init()
        self.currentSession = self.load()
    }
    
    private func getUrl(file: String) throws -> URL {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let output = supportDirectory.appendingPathComponent("\(SessionService.root)/\(file)")

        try fileManager.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        return output
    }
    
    public func save(response: SessionInfo) {
        do {
            self.currentSession = response
            let fileURL = try self.getUrl(file: SessionService.loginResponseFile)
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            try encoder.encode(response).write(to: fileURL)

        } catch {
            print("Unable to encode login: \(error)")
        }
    }
    
    public func load() -> SessionInfo? {
        if self.currentSession != nil {
            return self.currentSession
        }
        
        do {
            let fileURL = try self.getUrl(file: SessionService.loginResponseFile)
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(SessionInfo.self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    public func isSessionActive() -> Bool {
        return self.currentSession != nil
    }
    
    public func destroy() {
        do {
            let fileURL = try self.getUrl(file: SessionService.loginResponseFile)
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Unable to destroy the session: \(error)")
        }
        
        self.currentSession = nil
    }
    
    public func getLemmyInstance() -> String {
        if self.currentSession == nil {
            return SessionService.defaultLemmy
        }
        
        return self.currentSession!.lemmyInstance
    }
}
