//
//  ModRemoveComment.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModRemoveComment: Codable {
    let id: Int
    let modInt: Int
    let commentId: Int
    let reason: String?
    let removed: Bool
    let when_: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modInt = try container.decode(Int.self, forKey: .modInt)
        self.commentId = try container.decode(Int.self, forKey: .commentId)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
    }
}
