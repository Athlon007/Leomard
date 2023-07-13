//
//  CommentReply.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct CommentReply: Codable, Hashable {
    let commentId: Int
    let id: Int
    let published: Date
    var read: Bool
    let recipientId: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(Int.self, forKey: .commentId)
        self.id = try container.decode(Int.self, forKey: .id)
        self.read = try container.decode(Bool.self, forKey: .read)
        self.recipientId = try container.decode(Int.self, forKey: .recipientId)
        
        let publishedString: String = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
    }
}
