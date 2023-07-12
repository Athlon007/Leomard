//
//  PrivateMessage.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct PrivateMessage: Codable, Hashable {
    let apId: String
    let content: String
    let creatorId: Int
    let deleted: Bool
    let id: Int
    let local: Bool
    let published: Date
    let read: Bool
    let recipientId: Int
    let updated: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apId = try container.decode(String.self, forKey: .apId)
        self.content = try container.decode(String.self, forKey: .content)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.id = try container.decode(Int.self, forKey: .id)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.read = try container.decode(Bool.self, forKey: .read)
        self.recipientId = try container.decode(Int.self, forKey: .recipientId)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString == nil ? nil : try DateFormatConverter.formatToDate(from: updatedString!)
    }
}
