//
//  ModRemoveCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModRemoveCommunityView: Codable, Hashable {
    let modRemoveCommunity: ModRemoveCommunity
    let moderator: Person?
    let community: Community

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modRemoveCommunity = try container.decode(ModRemoveCommunity.self, forKey: .modRemoveCommunity)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.community = try container.decode(Community.self, forKey: .community)
    }
}
