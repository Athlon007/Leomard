//
//  Login.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct Login: Hashable, Codable {
    public let usernameOrEmail: String
    public let password: String
    public let totp2faToken: String?
}
