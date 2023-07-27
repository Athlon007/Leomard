//
//  Tagline.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct Tagline: Codable {
    public let id: Int
    public let content: String
    public let localSiteId: Int
    public let published: Date
    public let updated: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.localSiteId = try container.decode(Int.self, forKey: .localSiteId)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString == nil ? nil : try DateFormatConverter.formatToDate(from: updatedString!)
    }
}
