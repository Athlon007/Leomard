//
//  CommentReplyView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct CommentReplyView: Codable, Hashable {
    let comment: Comment
    let commentReply: CommentReply
    let community: Community
    let counts: CommentAggregates
    let creator: Person
    let creatorBannedFromCommunity: Bool
    let creatorBlocked: Bool
    let myVote: Int?
    let post: Post
    let recipient: Person
    let saved: Bool
    let subscribed: SubscribedType
}
