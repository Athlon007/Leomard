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
    case notLoggedIn(String)
    case unableToGetIcon(String)
    case userCancelledOperation(String)
    
    var description: String {
        switch self {
        case .versionFromStringDecodeError(let message):
            return message
        case .fileSizeTooLarge(let message):
            return message
        case .missingApiKey(let message):
            return message
        case .notLoggedIn(let message):
            return message
        case .unableToGetIcon(let message):
            return message
        case .userCancelledOperation(let message):
            return message
        }
    }
}
