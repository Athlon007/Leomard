//
//  AdminPurgePersonView.swift
//  Leomard
//
//  Created automatically by ts2swift on 03/08/2023.
//

import Foundation

struct AdminPurgePersonView: Codable {
    let adminPurgePerson: AdminPurgePerson
    let admin: Person?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.adminPurgePerson = try container.decode(AdminPurgePerson.self, forKey: .adminPurgePerson)
        self.admin = try container.decodeIfPresent(Person.self, forKey: .admin)
    }
}
