//
//  AdminPurgeComment.swift
//  Leomard
//
//  Created automatically by ts2swift on 03/08/2023.
//

import Foundation

struct AdminPurgeComment: Codable {
    let id: Int
    let adminInt: Int
    let postId: Int
    let reason: String?
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.adminInt = try container.decode(Int.self, forKey: .adminInt)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
