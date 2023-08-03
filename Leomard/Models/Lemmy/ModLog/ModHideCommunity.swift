//
//  ModHideCommunity.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModHideCommunity: Codable {
    let id: Int
    let communityId: Int
    let modInt: Int
    let when_: Date
    let reason: String?
    let hidden: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.modInt = try container.decode(Int.self, forKey: .modInt)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
    }
}
