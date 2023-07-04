//
//  Creator.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct Person: Hashable, Codable
{
    public let id: Int
    public let name: String
    public let displayName: String?
    public let avatar: String?
    public let banner: String?
    public let banned: Bool
    public let published: Date
    public let actorId: String
    public let bio: String?
    public let local: Bool
    public let deleted: Bool
    public let matrixUserId: String?
    public let admin: Bool
    public let botAccount: Bool
    public let instanceId: Int
    public let updated: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.banned = try container.decode(Bool.self, forKey: .banned)
        self.banner = try container.decodeIfPresent(String.self, forKey: .banner)
        
        
        let publishedString = try container.decode(String.self, forKey: .published)
        self.published = try DateFormatConverter.formatToDate(from: publishedString)
        
        self.actorId = try container.decode(String.self, forKey: .actorId)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.local = try container.decode(Bool.self, forKey: .local)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.matrixUserId = try container.decodeIfPresent(String.self, forKey: .matrixUserId)
        self.admin = try container.decode(Bool.self, forKey: .admin)
        self.botAccount = try container.decode(Bool.self, forKey: .botAccount)
        self.instanceId = try container.decode(Int.self, forKey: .instanceId)
        self.updated = try container.decodeIfPresent(String.self, forKey: .updated)
    }
}
