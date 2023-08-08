//
//  PostView.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct PostView: Hashable, Codable {
    public var post: Post
    public let creator: Person
    public let community: Community
    public let creatorBannedFromCommunity: Bool
    public var counts: PostAggregates
    public let subscribed: String
    public let saved: Bool
    public var read: Bool
    public let creatorBlocked: Bool
    public let unreadComments: Int
    public var myVote: Int?
}
