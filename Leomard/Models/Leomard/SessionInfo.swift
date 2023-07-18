//
//  SessionInfo.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct SessionInfo: Codable, Equatable {
    static func == (lhs: SessionInfo, rhs: SessionInfo) -> Bool {
        return lhs.name == rhs.name
        && lhs.lemmyInstance == rhs.lemmyInstance
        && lhs.loginResponse.jwt == rhs.loginResponse.jwt
    }
    
    public let loginResponse: LoginResponse
    public let lemmyInstance: String
    public let name: String
    
    init(loginResponse: LoginResponse, lemmyInstance: String, name: String) {
        self.loginResponse = loginResponse
        
        // Remove "http://" and "https://" from lemmyInstance.
        var correctedLink = lemmyInstance.replacingOccurrences(of: "https://", with: "")
        correctedLink = correctedLink.replacingOccurrences(of: "http://", with: "")
        
        self.lemmyInstance = correctedLink
        self.name = name
    }
}
