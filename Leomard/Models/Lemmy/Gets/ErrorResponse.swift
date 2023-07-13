//
//  Error.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation

protocol ErrorResponseProtocol: LocalizedError {
    var error: String { get }
}

struct ErrorResponse: Error, Codable {
    var error: String

    init(error: String) {
        self.error = error
    }
}
