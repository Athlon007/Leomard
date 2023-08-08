//
//  AdminPurgeCommunityView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct AdminPurgeCommunityView: Codable, Hashable {
    let adminPurgeCommunity: AdminPurgeCommunity
    let admin: Person?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.adminPurgeCommunity = try container.decode(AdminPurgeCommunity.self, forKey: .adminPurgeCommunity)
        self.admin = try container.decodeIfPresent(Person.self, forKey: .admin)
    }
}
