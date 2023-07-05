//
//  CommunityView.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct CommunityView: Codable {
    public let blocked: Bool
    public let community: Community
    public let counts: CommunityAggregates
    public let subscribed: SubscribedType
}
