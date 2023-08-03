//
//  ModFeaturePost.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModFeaturePost: Codable {
    let id: Int
    let modInt: Int
    let postId: Int
    let featured: Bool
    let when_: Date
    let isFeaturedCommunity: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modInt = try container.decode(Int.self, forKey: .modInt)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.featured = try container.decode(Bool.self, forKey: .featured)
        let when_String = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: when_String)
        self.isFeaturedCommunity = try container.decode(Bool.self, forKey: .isFeaturedCommunity)
    }
}
