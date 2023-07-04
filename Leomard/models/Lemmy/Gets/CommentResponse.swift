//
//  CommentResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation

struct CommentResponse: Codable {
    public let commentView: CommentView
    public let formId: String?
    public let recipientIds: [Int]
}
