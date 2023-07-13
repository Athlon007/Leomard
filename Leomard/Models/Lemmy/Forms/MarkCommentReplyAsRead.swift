//
//  MarkCommentReplyAsRead.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct MarkCommentReplyAsRead: Codable {
    let commentReplyId: Int
    let read: Bool
}
