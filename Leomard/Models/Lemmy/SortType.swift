//
//  SortType.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

enum SortType: String, Codable, CustomStringConvertible {
    case active
    case hot
    case new
    case old
    case topDay
    case topWeek
    case topMonth
    case topYear
    case topAll
    case mostComments
    case newComments
    case topHour
    case topSixHour
    case topTwelveHour
    
    static var allCases: [SortType] {
        return [.active, .hot, .new, .old, .topDay, .topWeek, .topMonth, .topYear, .topAll, .mostComments, .newComments, .topHour, .topSixHour, .topTwelveHour]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let variant = SortType.allCases.first(where: { $0.rawValue.capitalized == rawValue }) {
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
        case .active: return "bolt"
        case .hot: return "flame"
        case .new: return "clock"
        case .mostComments: return "ellipsis.message"
        case .topHour, .topDay, .topWeek, .topMonth, .topYear, .topAll: return "calendar"
        default: return ""
        }
    }
}
