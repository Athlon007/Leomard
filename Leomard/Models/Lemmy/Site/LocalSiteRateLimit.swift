//
//  LocalSiteRateLimit.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct LocalSiteRateLimit: Codable, Hashable {
    public let id: Int
    public let comment: Int
    public let commentPerSecond: Int
    public let image: Int
    public let imagePerSecond: Int
    public let localSiteId: Int
    public let message: Int
    public let messagePerSecond: Int
    public let post: Int
    public let postPerSecond: Int
    public let published: String
    public let register: Int
    public let registerPerSecond: Int
    public let search: Int
    public let searchPerSecond: Int
    public let updated: String?
}
