//
//  Error.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation

extension Error {
    func tryGetErrorMessage() -> String? {
        return (self as? ErrorResponse)?.error
    }
}
