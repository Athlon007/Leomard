//
//  ModHideCommunity.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModHideCommunity: Codable, Hashable {
    let id: Int
    let communityId: Int
    let modPersonId: Int
    let when_: Date
    let reason: String?
    let hidden: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.modPersonId = try container.decode(Int.self, forKey: .modPersonId)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
    }
}
