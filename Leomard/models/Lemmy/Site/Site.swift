//
//  Site.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct Site: Codable {
    public let id: Int
    public let actorId: String
    public let banner: String?
    public let description: String?
    public let icon: String?
    public let inboxUrl: String
    public let instanceId: Int
    public let lastRefreshedAt: String
    public let name: String
    public let privateKey: String?
    public let publicKey: String
    public let published: String
    public let sidebar: String?
    public let updated: String?
}
