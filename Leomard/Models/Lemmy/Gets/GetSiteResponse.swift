//
//  GetSiteResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct GetSiteResponse: Codable, Hashable {
    public let admins: [PersonView]
    public let allLanguages: [Language]
    public let customEmojis: [CustomEmojiView]
    public let discussionLanguages: [Int]
    public let myUser: MyUserInfo?
    public let siteView: SiteView
    public let taglines: [Tagline]
    public let version: String
}
