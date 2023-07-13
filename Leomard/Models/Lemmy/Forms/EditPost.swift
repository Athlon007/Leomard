//
//  EditPost.swift
//  Leomard
//
//  Created by Konrad Figura on 11/07/2023.
//

import Foundation

struct EditPost: Codable {
    let postId: Int
    let body: String?
    let honeypot: String?
    let languageId: Int?
    let name: String?
    let nsfw: Bool?
    let url: String?
}
