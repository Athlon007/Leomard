//
//  CreatePrivateMessage.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct CreatePrivateMessage: Codable {
    let content: String
    let recipientId: Int
}
