//
//  LoginResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

struct LoginResponse: Codable, Hashable, Equatable {
    public let jwt: String?
    public let registrationCreated: Bool
    public let verifyEmailSent: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jwt = try container.decodeIfPresent(String.self, forKey: .jwt)
        self.registrationCreated = try container.decode(Bool.self, forKey: .registrationCreated)
        self.verifyEmailSent = try container.decode(Bool.self, forKey: .verifyEmailSent)
    }
}
