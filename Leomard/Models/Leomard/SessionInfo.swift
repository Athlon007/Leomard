//
//  SessionInfo.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct SessionInfo: Codable {
    public let loginResponse: LoginResponse
    public let lemmyInstance: String
    
    init(loginResponse: LoginResponse, lemmyInstance: String) {
        self.loginResponse = loginResponse
        
        // Remove "http://" and "https://" from lemmyInstance.
        var correctedLink = lemmyInstance.replacingOccurrences(of: "https://", with: "")
        correctedLink = correctedLink.replacingOccurrences(of: "http://", with: "")
        
        self.lemmyInstance = correctedLink
    }
}
