//
//  CustomEmojiKeyword.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct CustomEmojiKeyword: Codable, Hashable {
    public let id: Int
    public let customEmojiId: Int
    public let keyword: String
}
