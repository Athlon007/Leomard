//
//  GetCaptchaResponse.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 11/08/2023.
//

import Foundation

struct GetCaptchaResponse: Codable, Hashable {
    let ok: CaptchaResponse?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ok = try container.decodeIfPresent(CaptchaResponse.self, forKey: .ok)
    }
}
