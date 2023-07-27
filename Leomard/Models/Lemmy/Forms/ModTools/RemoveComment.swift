//
//  RemoveComment.swift
//  Leomard
//
//  Created by Konrad Figura on 27/07/2023.
//

import Foundation

struct RemoveComment: Codable {
    let commentId: Int
    let reason: String?
    let removed: Bool
}
