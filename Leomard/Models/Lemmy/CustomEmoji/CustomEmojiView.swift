//
//  CustomEmojiView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct CustomEmojiView: Codable, Hashable {
    public let customEmoji: CustomEmoji
    public let keywords: [CustomEmojiKeyword]
}
