//
//  PostReportView.swift
//  Leomard
//
//  Created by Konrad Figura on 22/07/2023.
//

import Foundation

struct PostReportView: Codable {
    let community: Community
    let counts: PostAggregates
    let creator: Person
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let post: Post
    let postCreator: Person
    let postReport: PostReport
    let resolver: Person?
}
