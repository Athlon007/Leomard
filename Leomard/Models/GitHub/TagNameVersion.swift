//
//  TagNameVersion.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

struct TagNameVersion: Codable, Comparable {
    let major: Int
    let minor: Int
    let build: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let tagString = try container.decode(String.self)
        let versionComponents = tagString.split(separator: ".")
        let first = Int(versionComponents[0])
        
        if versionComponents.count == 0, first == nil {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid tag_name format")
        }
        
        var major = 0
        var minor = 0
        var build = 0
        
        if versionComponents.count >= 1 {
            major = Int(versionComponents[0]) ?? 0
        }
        
        if versionComponents.count >= 2 {
            minor = Int(versionComponents[1]) ?? 0
        }
                
        if versionComponents.count >= 3 {
            build = Int(versionComponents[2]) ?? 0
        }
                
        self.major = major
        self.minor = minor
        self.build = build
    }
    
    init(major: Int, minor: Int, build: Int) {
        self.major = major
        self.minor = minor
        self.build = build
    }
    
    init(textVersion: String) throws {
        let versionComponents = textVersion.split(separator: ".")
        let first = Int(versionComponents[0])
        
        if versionComponents.count == 0 || first == nil {
            throw LeomardExceptions.versionFromStringDecodeError("Failed to decode \(textVersion)")
        }
        
        var major = 0
        var minor = 0
        var build = 0
        
        if versionComponents.count >= 1 {
            major = Int(versionComponents[0]) ?? 0
        }
        
        if versionComponents.count >= 2 {
            minor = Int(versionComponents[1]) ?? 0
        }
        
        if versionComponents.count >= 3 {
            build = Int(versionComponents[2]) ?? 0
        }
        
        self.major = major
        self.minor = minor
        self.build = build
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(major).\(minor).\(build)")
    }
    
    static func < (lhs: TagNameVersion, rhs: TagNameVersion) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major {
            if lhs.minor < rhs.minor {
                return true
            } else if lhs.minor == rhs.minor {
                if lhs.build < rhs.build {
                    return true
                }
            }
        }
        
        return false
    }
}
