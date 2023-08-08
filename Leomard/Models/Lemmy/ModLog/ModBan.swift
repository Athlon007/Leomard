//
//  ModBan.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModBan: Codable, Hashable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modPersonId = try container.decode(Int.self, forKey: .modPersonId)
        self.otherPersonId = try container.decode(Int.self, forKey: .otherPersonId)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.banned = try container.decode(Bool.self, forKey: .banned)
        self.expires = try container.decodeIfPresent(String.self, forKey: .expires)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
