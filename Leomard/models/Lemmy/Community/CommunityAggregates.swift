//
//  CommunityAggregates.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct CommunityAggregates: Codable {
    public let id: Int
    public let comments: Int
    public let communityId: Int
    public let hotRank: Int
    public let posts: Int
    public let published: Date
    public let subscribers: Int
    public let usersActiveDay: Int
    public let usersActiveHalfYear: Int
    public let usersActiveMonth: Int
    public let usersActiveWeek: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.comments = try container.decode(Int.self, forKey: .comments)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.hotRank = try container.decode(Int.self, forKey: .hotRank)
        self.posts = try container.decode(Int.self, forKey: .posts)
        self.subscribers = try container.decode(Int.self, forKey: .subscribers)
        self.usersActiveDay = try container.decode(Int.self, forKey: .usersActiveDay)
        self.usersActiveHalfYear = try container.decode(Int.self, forKey: .usersActiveHalfYear)
        self.usersActiveMonth = try container.decode(Int.self, forKey: .usersActiveMonth)
        self.usersActiveWeek = try container.decode(Int.self, forKey: .usersActiveWeek)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
    }
}
