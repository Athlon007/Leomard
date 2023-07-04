//
//  Counts.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct PostAggregates: Hashable, Codable
{
    public let id: Int
    public let postId: Int
    public let comments: Int
    public let score: Int
    public let upvotes: Int
    public let downvotes: Int
    public let published: Date
    public let newestCommentTimeNecro: Date
    public let newestCommentTime: Date
    public let featuredCommunity: Bool
    public let featuredLocal: Bool
    public let hotRank: Int
    public let hotRankActive: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.comments = try container.decode(Int.self, forKey: .comments)
        self.score = try container.decode(Int.self, forKey: .score)
        self.upvotes = try container.decode(Int.self, forKey: .upvotes)
        self.downvotes = try container.decode(Int.self, forKey: .downvotes)
        
        let publishedDate = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedDate)
        let newestCommentTimeNecroString = try container.decode(String.self, forKey: .newestCommentTimeNecro)
        self.newestCommentTimeNecro = try DateFormatConverter.formatToDate(from: newestCommentTimeNecroString)
        let newestCommentTimeString = try container.decode(String.self, forKey: .newestCommentTime)
        self.newestCommentTime = try DateFormatConverter.formatToDate(from: newestCommentTimeString)
        
        self.featuredCommunity = try container.decode(Bool.self, forKey: .featuredCommunity)
        self.featuredLocal = try container.decode(Bool.self, forKey: .featuredLocal)
        self.hotRank = try container.decode(Int.self, forKey: .hotRank)
        self.hotRankActive = try container.decode(Int.self, forKey: .hotRankActive)
    }
}
