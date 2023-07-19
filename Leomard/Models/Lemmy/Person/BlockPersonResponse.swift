//
//  BlockPersonResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 19/07/2023.
//

import Foundation

struct BlockPersonResponse: Codable {
    let blocked: Bool
    let personView: PersonView
}
