//
//  Post.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct Post: Hashable, Codable
{
    public let id: Int
    public let name: String
    public let body: String?
    public let creatorId: Int
    public let communityId: Int
    public let removed: Bool
    public let locked: Bool
    public let published: Date
    public let updated: Date?
    public let deleted: Bool
    public let nsfw: Bool
    public let apId: String
    public let local: Bool
    public let languageId: Int
    public let featuredCommunity: Bool
    public let featuredLocal: Bool
    public let url: String?
    public let thumbnailUrl: String?
    public let embedTitle: String?
    public let embedDescription: String?
    public let embedVideoUrl: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        self.locked = try container.decode(Bool.self, forKey: .locked)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString: String? = try container.decodeIfPresent(String.self, forKey: .updated)
        if updatedString != nil {
            self.updated = try DateFormatConverter.formatToDate(from: updatedString!)
        } else {
            self.updated = nil
        }
        
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.nsfw = try container.decode(Bool.self, forKey: .nsfw)
        self.apId = try container.decode(String.self, forKey: .apId)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.languageId = try container.decode(Int.self, forKey: .languageId)
        self.featuredCommunity = try container.decode(Bool.self, forKey: .featuredCommunity)
        self.featuredLocal = try container.decode(Bool.self, forKey: .featuredLocal)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        self.embedTitle = try container.decodeIfPresent(String.self, forKey: .embedTitle)
        self.embedDescription = try container.decodeIfPresent(String.self, forKey: .embedDescription)
        self.embedVideoUrl = try container.decodeIfPresent(String.self, forKey: .embedVideoUrl)
    }
}
