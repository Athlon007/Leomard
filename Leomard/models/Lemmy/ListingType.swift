//
//  ListingType.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

enum ListingType: String, Codable, CustomStringConvertible {
    case all
    case local
    case subscribed
    
    static var allCases: [ListingType] {
        return [.all, .local, .subscribed]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let variant = ListingType.allCases.first(where: { $0.rawValue.capitalized == rawValue }) {
            self = variant
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid listing type value: \(rawValue)")
        }
    }
    
    var description: String {
        let lowercasedString = self.rawValue
        let firstCharacter = String(lowercasedString.prefix(1)).capitalized
        let remainingCharacters = String(lowercasedString.dropFirst())
        return firstCharacter + remainingCharacters
    }
    
    var image: String {
        switch self {
        case .all: return "globe"
        case .local: return "mappin"
        case .subscribed: return "star"
        }
    }
}
