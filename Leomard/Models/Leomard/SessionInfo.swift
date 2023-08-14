//
//  SessionInfo.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct SessionInfo: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    public var loginResponse: LoginResponse
    public let lemmyInstance: String
    public let name: String
    
    public var likedPosts: [Int]
    
    init(loginResponse: LoginResponse, lemmyInstance: String, name: String) {
        self.loginResponse = loginResponse
        
        // Remove "http://" and "https://" from lemmyInstance.
        var correctedLink = lemmyInstance.replacingOccurrences(of: "https://", with: "")
        correctedLink = correctedLink.replacingOccurrences(of: "http://", with: "")
        
        self.lemmyInstance = correctedLink
        self.name = name
        self.likedPosts = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.loginResponse = try container.decode(LoginResponse.self, forKey: .loginResponse)
        self.lemmyInstance = try container.decode(String.self, forKey: .lemmyInstance)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.likedPosts = try container.decodeIfPresent([Int].self, forKey: .likedPosts) ?? []
    }
    
    static func == (lhs: SessionInfo, rhs: SessionInfo) -> Bool {
        return lhs.name == rhs.name
        && lhs.lemmyInstance == rhs.lemmyInstance
        && lhs.loginResponse.jwt == rhs.loginResponse.jwt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(lemmyInstance)
    }
}
