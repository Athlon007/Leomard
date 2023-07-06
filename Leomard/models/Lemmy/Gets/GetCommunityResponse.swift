//
//  GetCommunityResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation

struct GetCommunityResponse: Codable {
    public let communityView: CommunityView
    public let discussionLanguages: [Int]
    public let moderators: [CommunityModeratorView]
    public let site: Site?
}
