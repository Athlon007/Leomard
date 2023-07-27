//
//  RegistrationMode.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

enum RegistrationMode: String, Codable, CustomStringConvertible {
    case closed
    case requireApplication
    case open
    
    static var allCases: [RegistrationMode] {
        return [.closed, .requireApplication, .open]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let variant = RegistrationMode.allCases.first(where: { $0.rawValue.uppercased() == rawValue.uppercased() }) {
            self = variant
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid registration type value: \(rawValue)")
        }
    }
    
    var description: String {
        let lowercasedString = self.rawValue
        let firstCharacter = String(lowercasedString.prefix(1)).capitalized
        let remainingCharacters = String(lowercasedString.dropFirst())
        return firstCharacter + remainingCharacters
    }
}
