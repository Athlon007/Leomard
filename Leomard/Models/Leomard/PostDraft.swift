//
//  PostDraft.swift
//  Leomard
//
//  Created by Konrad Figura on 09/08/2023.
//

import Foundation

struct PostDraft: Codable, Hashable {
    let title: String
    let body: String
    let url: String
    let nsfw: Bool
    var fileName: String = ""
}
