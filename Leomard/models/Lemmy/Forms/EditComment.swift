//
//  EditComment.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct EditComment: Codable {
    public let commentId: Int
    public let content: String?
    public let formId: String?
    public let languageId: Int?
}
