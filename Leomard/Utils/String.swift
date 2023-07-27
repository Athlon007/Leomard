//
//  String.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

extension String {
    /// This method catches all images in Markdonw text, and then adds new lines before and after it.
    /// We're doing it, because MarkdownUI tries to render those images in-line, often resulting in those overflowing the container and cutting-off the image.
    /// Markdown UI itself does not provide a way to tell it to move images to the next line, so we do it manually.
    func formatMarkdown(formatImages: Bool = true) async -> String {
        return await withCheckedContinuation { continuation in
            Task(priority: .background) {
                var transformed = self
                if formatImages {
                    transformed = addSpacesBetweenImages(transformed)
                }
                transformed = convertPersonsLinks(input: transformed)
                transformed = convertInstanceLinks(input: transformed)
                
                return continuation.resume(returning: String(transformed))
            }
        }
    }
    
    func containsAny(_ haystack: String...) -> Bool {
        for needle in haystack {
            if self.contains(needle) {
                return true
            }
        }
        
        return false
    }
    
    private func addSpacesBetweenImages(_ text: String) -> String {
        let pattern = #"!\[.*?\]\(.*?\)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let mutableMarkdownText = NSMutableString(string: text)
        var offset = 0
        
        regex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) { (match, _, _) in
            if let match = match {
                let range = match.range
                let location = range.location + offset
                // Insert two line breaks before and after the image
                let replacement = "\n\n\(text[Range(range, in: text)!])\n\n"
                
                mutableMarkdownText.replaceCharacters(in: NSRange(location: location, length: range.length), with: replacement)
                offset += replacement.utf16.count - range.length
            }
        }
        
        return String(mutableMarkdownText)
    }
    
    private func convertInstanceLinks(input: String) -> String {
        let pattern = "@[a-zA-Z0-9\\.]+@[a-zA-Z0-9\\.]+" // Regular expression pattern to match "@<any text without spaces>@<hostname>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        var result = input
        
        for match in matches.reversed() {
            let matchedString = (input as NSString).substring(with: match.range)
            let markdownLink = "[\(matchedString)](leomard:\(matchedString))"
            result = (result as NSString).replacingCharacters(in: match.range, with: markdownLink)
        }
        
        return result
    }
    
    private func convertPersonsLinks(input: String) -> String {
        let pattern = "![a-zA-Z0-9\\.]+@[a-zA-Z0-9\\.]+" // Regular expression pattern to match "@<any text without spaces>@<hostname>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        var result = input
        
        for match in matches.reversed() {
            let matchedString = (input as NSString).substring(with: match.range)
            let markdownLink = "[\(matchedString)](leomard:\(matchedString))"
            result = (result as NSString).replacingCharacters(in: match.range, with: markdownLink)
        }
        
        return result
    }
}
