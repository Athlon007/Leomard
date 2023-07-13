//
//  LocalUser.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct LocalUser: Codable {
    public let id: Int
    public let acceptedApplication: Bool
    public let defaultListingType: ListingType
    public let defaultSortType: SortType
    public let email: String?
    public let emailVerified: Bool
    public let interfaceLanguage: String
    public let personId: Int
    public let sendNotificationsToEmail: Bool
    public let showAvatars: Bool
    public let showBotAccounts: Bool
    public let showNewPostNotifs: Bool
    public let showNsfw: Bool
    public let showReadPosts: Bool
    public let showScores: Bool
    public let theme: String
    public let totp2faUrl: String?
    public let validatorTime: String
}
