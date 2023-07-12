//
//  CommentReplyView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct CommentReplyView: Codable, Hashable {
    var comment: Comment
    var commentReply: CommentReply
    let community: Community
    var counts: CommentAggregates
    let creator: Person
    let creatorBannedFromCommunity: Bool
    let creatorBlocked: Bool
    var myVote: Int?
    let post: Post
    let recipient: Person
    var saved: Bool
    let subscribed: SubscribedType
}
