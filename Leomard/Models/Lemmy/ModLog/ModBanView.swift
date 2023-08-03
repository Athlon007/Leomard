//
//  ModBanView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModBanView: Codable {
    let modBan: ModBan
    let moderator: Person?
    let bannedPerson: Person

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modBan = try container.decode(ModBan.self, forKey: .modBan)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.bannedPerson = try container.decode(Person.self, forKey: .bannedPerson)
    }
}
