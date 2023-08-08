//
//  ModHideCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModHideCommunityView: Codable, Hashable {
    let modHideCommunity: ModHideCommunity
    let admin: Person?
    let community: Community

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modHideCommunity = try container.decode(ModHideCommunity.self, forKey: .modHideCommunity)
        self.admin = try container.decodeIfPresent(Person.self, forKey: .admin)
        self.community = try container.decode(Community.self, forKey: .community)
    }
}
