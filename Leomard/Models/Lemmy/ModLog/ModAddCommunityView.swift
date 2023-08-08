//
//  ModAddCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModAddCommunityView: Codable, Hashable {
    let modAddCommunity: ModAddCommunity
    let moderator: Person?
    let community: Community
    let moddedPerson: Person

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modAddCommunity = try container.decode(ModAddCommunity.self, forKey: .modAddCommunity)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.community = try container.decode(Community.self, forKey: .community)
        self.moddedPerson = try container.decode(Person.self, forKey: .moddedPerson)
    }
}
