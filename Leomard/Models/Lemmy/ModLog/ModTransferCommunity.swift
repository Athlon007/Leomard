//
//  ModTransferCommunity.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModTransferCommunity: Codable {
    let id: Int
    let modInt: Int
    let otherInt: Int
    let communityId: Int
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modInt = try container.decode(Int.self, forKey: .modInt)
        self.otherInt = try container.decode(Int.self, forKey: .otherInt)
        self.communityId = try container.decode(Int.self, forKey: .communityId)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
