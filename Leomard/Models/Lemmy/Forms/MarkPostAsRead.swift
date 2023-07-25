//
//  MarkPostAsRead.swift
//  Leomard
//
//  Created by Konrad Figura on 25/07/2023.
//

import Foundation

struct MarkPostAsRead: Codable {
    let postId: Int
    let read: Bool
}
