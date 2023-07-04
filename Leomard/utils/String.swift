//
//  String.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

extension String {
    func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString(self)
        }
    }
}
