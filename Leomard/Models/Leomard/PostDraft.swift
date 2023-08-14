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
    var created: Date = .init(timeIntervalSince1970: 0)

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.url = try container.decode(String.self, forKey: .url)
        self.nsfw = try container.decode(Bool.self, forKey: .nsfw)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.created = try container.decodeIfPresent(Date.self, forKey: .created) ?? Date(timeIntervalSince1970: 0)
    }
    
    init(title: String, body: String, url: String, nsfw: Bool) {
        self.title = title
        self.body = body
        self.url = url
        self.nsfw = nsfw
    }
}
