//
//  PostView.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct PostView: Hashable, Codable
{
    public let post: Post
    public let creator: Person
    public let community: Community
    public let creatorBannedFromCommunity: Bool
    public let counts: PostAggregates
    public let subscribed: String
    public let saved: Bool
    public let read: Bool
    public let creatorBlocked: Bool
    public let unreadComments: Int
}
