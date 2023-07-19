//
//  BlockCommunityResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 19/07/2023.
//

import Foundation

struct BlockCommunityResponse: Codable {
    let blocked: Bool
    let communityView: CommunityView
}
