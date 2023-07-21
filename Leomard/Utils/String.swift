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
    func formatMarkdown() -> String {
        let pattern = #"!\[.*?\]\(.*?\)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let mutableMarkdownText = NSMutableString(string: self)
        var offset = 0
        
        regex.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) { (match, _, _) in
            if let match = match {
                let range = match.range
                let location = range.location + offset
                // Insert two line breaks before and after the image
                let replacement = "\n\n\(self[Range(range, in: self)!])\n\n"
                
                mutableMarkdownText.replaceCharacters(in: NSRange(location: location, length: range.length), with: replacement)
                offset += replacement.utf16.count - range.length
            }
        }
        
        return String(mutableMarkdownText)
    }
}
