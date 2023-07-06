//
//  CommunityResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

struct CommunityResponse: Codable {
    public let communityView: CommunityView
    public let discussionLanguages: [Int]
}
