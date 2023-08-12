//
//  Register.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 11/08/2023.
//

import Foundation

struct Register: Codable {
    let username: String
    let password: String
    let passwordVerify: String
    let showNsfw: Bool
    let email: String?
    let captchaUuid: String?
    let captchaAnswer: String?
    let answer: String?
}
