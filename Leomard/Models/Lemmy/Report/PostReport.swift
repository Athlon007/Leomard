//
//  PostReport.swift
//  Leomard
//
//  Created by Konrad Figura on 22/07/2023.
//

import Foundation

struct PostReport: Codable {
    let creatorId: Int
    let id: Int
    let originalPostBody: String?
    let originalPostName: String
    let originalPostUrl: String?
    let postId: Int
    let published: Date
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let updated: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.id = try container.decode(Int.self, forKey: .id)
        self.originalPostBody = try container.decodeIfPresent(String.self, forKey: .originalPostBody)
        self.originalPostName = try container.decode(String.self, forKey: .originalPostName)
        self.originalPostUrl = try container.decodeIfPresent(String.self, forKey: .originalPostUrl)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.reason = try container.decode(String.self, forKey: .reason)
        self.resolved = try container.decode(Bool.self, forKey: .resolved)
        self.resolverId = try container.decodeIfPresent(Int.self, forKey: .resolverId)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString == nil ? nil : try DateFormatConverter.formatToDate(from: updatedString!)
    }
}
