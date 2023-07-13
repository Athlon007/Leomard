//
//  Option.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct Option: Hashable {
    let id: Int
    var title: String
    let imageName: String
    var externalLink: String?
    var badgeText: String?
}
