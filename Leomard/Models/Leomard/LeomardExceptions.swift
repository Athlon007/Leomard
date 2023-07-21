//
//  Exceptions.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

enum LeomardExceptions: Error {
    case versionFromStringDecodeError(String)
    case fileSizeTooLarge(String)
}
