//
//  GetPostResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct GetPostResponse: Codable {
    public let communityView: CommunityView
    public let crossPosts: [PostView]
    public let moderators: [CommunityModeratorView]
    public let postView: PostView
}
