//
//  PrivateMessageView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct PrivateMessageView: Codable, Hashable {
    let creator: Person
    let privateMessage: PrivateMessage
    let recipient: Person
}
