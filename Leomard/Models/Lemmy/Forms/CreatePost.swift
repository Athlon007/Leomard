//
//  CreatePost.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation

struct CreatePost: Codable {
    let body: String?
    let communityId: Int
    let honeypot: String?
    let languageId: Int?
    let name: String
    let nsfw: Bool?
    let url: String?
}
