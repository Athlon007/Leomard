//
//  CommentAggregates.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct CommentAggregates: Codable, Hashable {
    public let childCount: Int
    public let commentId: Int
    public let downvotes: Int
    public let hotRank: Int
    public let id: Int
    public let published: Date
    public let score: Int
    public let upvotes: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.childCount = try container.decode(Int.self, forKey: .childCount)
        self.commentId = try container.decode(Int.self, forKey: .commentId)
        self.downvotes = try container.decode(Int.self, forKey: .downvotes)
        self.hotRank = try container.decode(Int.self, forKey: .hotRank)
        self.id = try container.decode(Int.self, forKey: .id)
        self.score = try container.decode(Int.self, forKey: .score)
        self.upvotes = try container.decode(Int.self, forKey: .upvotes)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
    }
}
