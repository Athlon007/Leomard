//
//  SaveUserSettings.swift
//  Leomard
//
//  Created by Konrad Figura on 26/07/2023.
//

import Foundation

struct SaveUserSettings: Codable {
    let avatar: String?
    let banner: String?
    let bio: String?
    let displayName: String?
}
