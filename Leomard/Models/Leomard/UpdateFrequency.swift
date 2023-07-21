//
//  UpdateFrequency.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

enum UpdateFrequency: String, CustomStringConvertible {
    case never
    case everyLaunch
    case onceADay
    case onceAWeek
    
    static var allCases: [UpdateFrequency] {
        return [ .never, .everyLaunch, .onceADay, .onceAWeek ]
    }
    
    var description: String {
        switch self {
        case .never: return "Never"
        case .everyLaunch: return "Every launch"
        case .onceADay: return "Once a day"
        case .onceAWeek: return "Once a week"
        }
    }
}
