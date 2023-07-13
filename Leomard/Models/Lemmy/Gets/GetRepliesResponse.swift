//
//  GetRepliesResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct GetRepliesResponse: Codable, Hashable {
    let replies: [CommentReplyView]
}
