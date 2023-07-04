//
//  Community.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct Community: Hashable, Codable
{
    public let id: Int
    public let name: String
    public let title: String
    public let banner: String?
    public let description: String?
    public let removed: Bool
    public let published: Date
    public let updated: Date?
    public let deleted: Bool
    public let nsfw: Bool
    public let actorId: String
    public let local: Bool
    public let icon: String?
    public let hidden: Bool
    public let postingRestrictedToMods: Bool
    public let instanceId: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .title)
        self.banner = try container.decodeIfPresent(String.self, forKey: .banner)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        
        let publishedString = try container.decode(String.self, forKey: .published)
        let updatedString: String? = try container.decodeIfPresent(String.self, forKey: .updated)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        if updatedString != nil {
            self.updated = try DateFormatConverter.formatToDate(from: updatedString!)
        } else {
            self.updated = nil
        }
        
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.nsfw = try container.decode(Bool.self, forKey: .nsfw)
        self.actorId = try container.decode(String.self, forKey: .actorId)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        self.postingRestrictedToMods = try container.decode(Bool.self, forKey: .postingRestrictedToMods)
        self.instanceId = try container.decode(Int.self, forKey: .instanceId)
    }
}
