//
//  CommentSortType.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

enum CommentSortType: String, Codable, CustomStringConvertible {
    case hot
    case top
    case new
    case old
    
    static var allCases: [CommentSortType] {
        return [ .hot, .top, .new, .old ]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let variant = CommentSortType.allCases.first(where: { $0.rawValue.capitalized == rawValue }) {
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
}
