//
//  YoutubeVideosPreference.swift
//  Leomard
//
//  Created by Konrad Figura on 16/08/2023.
//

import Foundation

enum YoutubeVideoPreference: String, CustomStringConvertible {
    case preferLink
    case preferYoutube
    case preferPiped
    
    static var allCases: [YoutubeVideoPreference] {
        return [ .preferLink, .preferYoutube, .preferPiped ]
    }
    
    var description: String {
        switch self {
        case .preferLink: return "Linked Player"
        case .preferYoutube: return "YouTube"
        case .preferPiped: return "Piped"
        }
    }
}
