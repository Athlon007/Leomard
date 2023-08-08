//
//  AdminPurgeComment.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct AdminPurgeComment: Codable, Hashable {
    let id: Int
    let adminPersonId: Int
    let postId: Int
    let reason: String?
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.adminPersonId = try container.decode(Int.self, forKey: .adminPersonId)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
