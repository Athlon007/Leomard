//
//  SiteAggregates.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct SiteAggregates: Codable {
    public let id: Int
    public let comments: Int
    public let communities: Int
    public let posts: Int
    public let siteId: Int
    public let users: Int
    public let usersActiveDay: Int
    public let usersActiveHalfYear: Int
    public let usersActiveMonth: Int
    public let usersActiveWeek: Int
}
