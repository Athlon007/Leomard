//
//  ModlogActionType.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

enum ModlogActionType: String, Codable, CustomStringConvertible {
    case all
    case modRemovePost
    case modLockPost
    case modFeaturePost
    case modRemoveComment
    case modRemoveCommunity
    case modBanFromCommunity
    case modAddCommunity
    case modTransferCommunity
    case modAdd
    case modBan
    case modHideCommunity
    case adminPurgePerson
    case adminPurgeCommunity
    case adminPurgePost
    case adminPurgeComment

    static let allCases: [ModlogActionType] = [
        all,
        modRemovePost,
        modLockPost,
        modFeaturePost,
        modRemoveComment,
        modRemoveCommunity,
        modBanFromCommunity,
        modAddCommunity,
        modTransferCommunity,
        modAdd,
        modBan,
        modHideCommunity,
        adminPurgePerson,
        adminPurgeCommunity,
        adminPurgePost,
        adminPurgeComment
    ]
    
    static let allCasesCommunity: [ModlogActionType] = [
            modRemovePost,
            modLockPost,
            modFeaturePost,
            modRemoveComment,
            modRemoveCommunity,
            modBanFromCommunity,
            modAddCommunity,
            modTransferCommunity
        ]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let variant = ModlogActionType.allCases.first(where: { $0.rawValue.uppercased() == rawValue.uppercased() }) {
            self = variant
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value: \(rawValue)")
        }
    }

    var description: String {
        let lowercasedString = self.rawValue
        let firstChar = lowercasedString.prefix(1).uppercased()
        let otherChars = lowercasedString.dropFirst()
        return firstChar + otherChars
    }
}
