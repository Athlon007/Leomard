//
//  EditCommunity.swift
//  Leomard
//
//  Created by Konrad Figura on 27/07/2023.
//

import Foundation

struct EditCommunity: Codable {
    let communityId: Int
    let description: String?
    let nsfw: Bool?
    let postingRestrictedToMods: Bool?
    let title: String?
}
