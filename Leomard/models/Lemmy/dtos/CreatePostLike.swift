//
//  CreatePost.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation

struct CreatePostLike: Codable {
    public let postId: Int
    public let score: Int
}

struct CreatePostLikeTest: Codable {
    public let postId: Int
    public let score: Int
    public let auth: String
}
