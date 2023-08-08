//
//  Post.swift
//  Leomard
//
//  Created automatically by ts2swift on 03/08/2023.
//

import Foundation

struct Post: Codable, Hashable {
    let id: Int
    let name: String
    let url: String?
    let body: String?
    let creatorId: Int
    let communityId: Int
    let removed: Bool
    let locked: Bool
    let published: Date
    let updated: Date?
    var deleted: Bool
    let nsfw: Bool
    let embedTitle: String?
    let embedDescription: String?
    let thumbnailUrl: String?
    let apId: String
    let local: Bool
    let embedVideoUrl: String?
    let languageId: Int
    let featuredCommunity: Bool
    let featuredLocal: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        self.locked = try container.decode(Bool.self, forKey: .locked)
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString != nil ? try DateFormatConverter.formatToDate(from: updatedString!) : nil
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.nsfw = try container.decode(Bool.self, forKey: .nsfw)
        self.embedTitle = try container.decodeIfPresent(String.self, forKey: .embedTitle)
        self.embedDescription = try container.decodeIfPresent(String.self, forKey: .embedDescription)
        self.thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        self.apId = try container.decode(String.self, forKey: .apId)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.embedVideoUrl = try container.decodeIfPresent(String.self, forKey: .embedVideoUrl)
        self.languageId = try container.decode(Int.self, forKey: .languageId)
        self.featuredCommunity = try container.decode(Bool.self, forKey: .featuredCommunity)
        self.featuredLocal = try container.decode(Bool.self, forKey: .featuredLocal)
    }
}
