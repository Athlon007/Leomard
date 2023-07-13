//
//  File.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct MarkPrivateMessageAsRead: Codable {
    let privateMessageId: Int
    let read: Bool
}
