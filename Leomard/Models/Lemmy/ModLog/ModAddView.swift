//
//  ModAddView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModAddView: Codable, Hashable {
    let modAdd: ModAdd
    let moderator: Person?
    let moddedPerson: Person

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modAdd = try container.decode(ModAdd.self, forKey: .modAdd)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.moddedPerson = try container.decode(Person.self, forKey: .moddedPerson)
    }
}
