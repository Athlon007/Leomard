//
//  CustomEmoji.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct CustomEmoji: Codable {
    public let id: Int
    public let altText: String
    public let category: String
    public let imageUrl: String
    public let localSiteId: Int
    public let shortcode: String
    public let published: Date
    public let updated: Date?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.altText = try container.decode(String.self, forKey: .altText)
        self.category = try container.decode(String.self, forKey: .category)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.localSiteId = try container.decode(Int.self, forKey: .localSiteId)
        self.shortcode = try container.decode(String.self, forKey: .shortcode)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString != nil ? try DateFormatConverter.formatToDate(from: updatedString!) : nil
    }
}
