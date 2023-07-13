//
//  SearchType.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

enum SearchType: String, Codable, CustomStringConvertible {
    case all
    case comments
    case posts
    case communities
    case users
    case url
    
    static var allCases: [SearchType] {
        return [.all, .comments, .posts, .communities, .users, .url]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let variant = SearchType.allCases.first(where: { $0.rawValue.uppercased() == rawValue.uppercased() }) {
            self = variant
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid search type value: \(rawValue)")
        }
    }
    
    var description: String {
        let lowercasedString = self.rawValue
        let firstCharacter = String(lowercasedString.prefix(1)).capitalized
        let remainingCharacters = String(lowercasedString.dropFirst())
        return firstCharacter + remainingCharacters
    }
}
