//
//  GetModlog.swift
//  Leomard
//
//  Created automatically by ts2swift 1.1 on 04/08/2023.
//

import Foundation

struct GetModlog: Codable {
    let modInt: Int?
    let communityId: Int?
    let page: Int?
    let limit: Int?
    let type: ModlogActionType?
    let otherInt: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modInt = try container.decodeIfPresent(Int.self, forKey: .modInt)
        self.communityId = try container.decodeIfPresent(Int.self, forKey: .communityId)
        self.page = try container.decodeIfPresent(Int.self, forKey: .page)
        self.limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        self.type = try container.decodeIfPresent(ModlogActionType.self, forKey: .type)
        self.otherInt = try container.decodeIfPresent(Int.self, forKey: .otherInt)
    }
}
