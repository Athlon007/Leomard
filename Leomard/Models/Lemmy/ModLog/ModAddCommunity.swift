//
//  ModAddCommunity.swift
//  Leomard
//
//  Created automatically by ts2swift on 03/08/2023.
//

import Foundation

struct ModAddCommunity: Codable {
    let id: Int
    let modInt: Int
    let otherInt: Int
    let communityId: Int
    let removed: Bool
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modInt = try container.decode(Int.self, forKey: .modInt)
        self.otherInt = try container.decode(Int.self, forKey: .otherInt)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
