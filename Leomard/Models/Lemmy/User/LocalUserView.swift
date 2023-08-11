//
//  LocalUserView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct LocalUserView: Codable, Hashable {
    public let localUser: LocalUser
    public let person: Person
    public let counts: PersonAggregates
}
