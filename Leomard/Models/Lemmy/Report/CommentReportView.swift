//
//  CommentReportView.swift
//  Leomard
//
//  Created by Konrad Figura on 22/07/2023.
//

import Foundation

struct CommentReportView: Codable {
    let comment: Comment
    let commentReport: CommentReport
    let community: Community
    let counts: CommentAggregates
    let creator: Person
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let post: Post
    let resolver: Person?
}
