//
//  Comment.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct Comment: Codable, Hashable {
    public let apId: String
    public let content: String
    public let creatorId: Int
    public let deleted: Bool
    public let distinguished: Bool
    public let id: Int
    public let languageId: Int
    public let local: Bool
    public let path: String
    public let postId: Int
    public let published: Date
    public let removed: Bool
    public let updated: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apId = try container.decode(String.self, forKey: .apId)
        self.content = try container.decode(String.self, forKey: .content)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.distinguished = try container.decode(Bool.self, forKey: .distinguished)
        self.id = try container.decode(Int.self, forKey: .id)
        self.languageId = try container.decode(Int.self, forKey: .languageId)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.path = try container.decode(String.self, forKey: .path)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString != nil ? try DateFormatConverter.formatToDate(from: updatedString!) : nil
    }
}
