//
//  Sessions.swift
//  Leomard
//
//  Created by Konrad Figura on 18/07/2023.
//

import Foundation

struct Sessions: Codable {
    var currentSession: SessionInfo?
    var allSessions: [SessionInfo] = []
}
