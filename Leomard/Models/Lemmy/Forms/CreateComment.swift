//
//  CreateComment.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct CreateComment: Codable {
    public let content: String
    public let formId: String?
    public let languageId: Int?
    public let parentId: Int?
    public let postId: Int
}
