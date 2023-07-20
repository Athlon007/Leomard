//
//  Release.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

struct Release: Codable {
    let htmlUrl: String
    let tagName: TagNameVersion
    let name: String
    let publishedAt: Date
    let assets: [ReleaseAsset]
    let body: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
        self.tagName = try container.decode(TagNameVersion.self, forKey: .tagName)
        self.name = try container.decode(String.self, forKey: .name)
        self.assets = try container.decode([ReleaseAsset].self, forKey: .assets)
        self.body = try container.decode(String.self, forKey: .body)
        
        let publishedAtString = try container.decode(String.self, forKey: .publishedAt)
        self.publishedAt = try DateFormatConverter.formatToDate(from: publishedAtString)
    }
}
