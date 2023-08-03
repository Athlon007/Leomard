//
//  ModTransferCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModTransferCommunityView: Codable {
    let modTransferCommunity: ModTransferCommunity
    let moderator: Person?
    let community: Community
    let moddedPerson: Person

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modTransferCommunity = try container.decode(ModTransferCommunity.self, forKey: .modTransferCommunity)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.community = try container.decode(Community.self, forKey: .community)
        self.moddedPerson = try container.decode(Person.self, forKey: .moddedPerson)
    }
}
