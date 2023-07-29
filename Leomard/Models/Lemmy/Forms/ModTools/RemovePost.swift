//
//  RemovePost.swift
//  Leomard
//
//  Created by Konrad Figura on 27/07/2023.
//

import Foundation

struct RemovePost: Codable {
    let postId: Int
    let reason: String?
    let removed: Bool
}
