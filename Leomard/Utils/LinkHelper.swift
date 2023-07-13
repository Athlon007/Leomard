//
//  LinkHelper.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

class LinkHelper {
    static func stripToHost(link: String) -> String {
        guard let url = URL(string: link) else {
            return ""
        }
        
        guard let host = url.host else {
            return ""
        }
        
        return host
    }
    
    static let imageFormats = [
        ".jpg",
        ".jpeg",
        ".webp",
        ".png",
        ".bmp"
    ]
    
    static func isImageLink(link: String) -> Bool {
        for format in imageFormats {
            if link.lowercased().hasSuffix(format) {
                return true
            }
        }
        
        return false
    }
    
    static let animatedFormats = [
        ".gif"
    ]
    
    static func isAnimatedLink(link: String) -> Bool {
        for format in animatedFormats {
            if link.lowercased().hasSuffix(format) {
                return true
            }
        }
        
        return false
    }
    
    static func isWebp(link: String) -> Bool {
        return link.lowercased().hasSuffix(".webp")
    }
    
    static let videoFormats = [
        ".mp4",
        ".avi"
    ]
    
    static func isVideosLink(link: String) -> Bool {
        for format in videoFormats {
            if link.lowercased().hasSuffix(format) {
                return true
            }
        }
        
        return false
    }
    
    static func isYouTubeLink(link: String) -> Bool {
        return link.contains("youtube.com") || link.contains("youtu.be")
    }
}
