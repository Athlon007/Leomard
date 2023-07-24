//
//  Exceptions.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

enum LeomardExceptions: Error, CustomStringConvertible {
    case versionFromStringDecodeError(String)
    case fileSizeTooLarge(String)
    case missingApiKey(String)
    
    var description: String {
        switch self {
        case .versionFromStringDecodeError(let message):
            return message
        case .fileSizeTooLarge(let message):
            return message
        case .missingApiKey(let message):
            return message
        }
    }
}
