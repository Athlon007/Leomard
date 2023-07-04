//
//  CommentView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct CommentView: Hashable, Codable {    
    public let comment: Comment
    public let community: Community
    public let counts: CommentAggregates
    public let creator: Person
    public let creatorBannedFromCommunity: Bool
    public let creatorBlocked: Bool
    public let myVote: Int?
    public let post: Post
    public let saved: Bool
    public let subscribed: SubscribedType
}
