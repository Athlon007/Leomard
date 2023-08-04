//
//  ModAddCommunityView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/08/2023.
//

import Foundation

struct ModAddCommunityView: Codable {
    let community: Community
    let modAddCommunity: ModAddCommunity
    let moddedPerson: Person
    let moderator: Person?
}
