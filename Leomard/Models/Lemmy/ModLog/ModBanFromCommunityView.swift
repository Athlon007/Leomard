//
//  ModBanFromCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModBanFromCommunityView: Codable, Hashable {
    let modBanFromCommunity: ModBanFromCommunity
    let moderator: Person?
    let community: Community
    let bannedPerson: Person

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modBanFromCommunity = try container.decode(ModBanFromCommunity.self, forKey: .modBanFromCommunity)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.community = try container.decode(Community.self, forKey: .community)
        self.bannedPerson = try container.decode(Person.self, forKey: .bannedPerson)
    }
}
