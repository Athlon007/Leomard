//
//  PersonView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct PersonView: Codable, Hashable {
    public let person: Person
    public let counts: PersonAggregates
}
