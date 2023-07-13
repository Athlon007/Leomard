//
//  PersonAggregates.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct PersonAggregates: Codable, Hashable {
    public let id: Int
    public let personId: Int
    public let commentCount: Int
    public let commentScore: Int
    public let postCount: Int
    public let postScore: Int
}
