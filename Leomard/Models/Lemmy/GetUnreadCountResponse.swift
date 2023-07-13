//
//  UnreadCounts.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

struct GetUnreadCountResponse: Codable {
    let mentions: Int
    let privateMessages: Int
    let replies: Int
    
    func total() -> Int {
        return mentions + privateMessages + replies
    }
}
