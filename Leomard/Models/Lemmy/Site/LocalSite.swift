//
//  LocalSite.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct LocalSite: Codable, Hashable {
    public let id: Int
    public let actorNameMaxLength: Int
    public let applicationEmailAdmins: Bool
    public let applicationQuestion: String?
    public let captchaDifficulty: String
    public let captchaEnabled: Bool
    public let communityCreationAdminOnly: Bool
    public let defaultPostListingType: ListingType
    public let defaultTheme: String
    public let enableDownvotes: Bool
    public let enableNsfw: Bool
    public let federationEnabled: Bool
    public let federationWorkerCount: Int?
    public let hideModlogModNames: Bool
    public let legalInformation: String?
    public let privateInstance: Bool
    public let published: String
    public let registrationMode: RegistrationMode
    public let reportsEmailAdmins: Bool
    public let requireEmailVerification: Bool
    public let siteId: Int
    public let siteSetup: Bool
    public let slurFilterRegex: String?
    public let updated: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.actorNameMaxLength = try container.decode(Int.self, forKey: .actorNameMaxLength)
        self.applicationEmailAdmins = try container.decode(Bool.self, forKey: .applicationEmailAdmins)
        self.applicationQuestion = try container.decodeIfPresent(String.self, forKey: .applicationQuestion)
        self.captchaDifficulty = try container.decode(String.self, forKey: .captchaDifficulty)
        self.captchaEnabled = try container.decode(Bool.self, forKey: .captchaEnabled)
        self.communityCreationAdminOnly = try container.decode(Bool.self, forKey: .communityCreationAdminOnly)
        self.defaultPostListingType = try container.decode(ListingType.self, forKey: .defaultPostListingType)
        self.defaultTheme = try container.decode(String.self, forKey: .defaultTheme)
        self.enableDownvotes = try container.decode(Bool.self, forKey: .enableDownvotes)
        self.enableNsfw = try container.decode(Bool.self, forKey: .enableNsfw)
        self.federationEnabled = try container.decode(Bool.self, forKey: .federationEnabled)
        self.federationWorkerCount = try container.decodeIfPresent(Int.self, forKey: .federationWorkerCount)
        self.hideModlogModNames = try container.decode(Bool.self, forKey: .hideModlogModNames)
        self.legalInformation = try container.decodeIfPresent(String.self, forKey: .legalInformation)
        self.privateInstance = try container.decode(Bool.self, forKey: .privateInstance)
        self.published = try container.decode(String.self, forKey: .published)
        self.registrationMode = try container.decode(RegistrationMode.self, forKey: .registrationMode)
        self.reportsEmailAdmins = try container.decode(Bool.self, forKey: .reportsEmailAdmins)
        self.requireEmailVerification = try container.decode(Bool.self, forKey: .requireEmailVerification)
        self.siteId = try container.decode(Int.self, forKey: .siteId)
        self.siteSetup = try container.decode(Bool.self, forKey: .siteSetup)
        self.slurFilterRegex = try container.decodeIfPresent(String.self, forKey: .slurFilterRegex)
        let updatedString = try container.decodeIfPresent(String.self, forKey: .updated)
        self.updated = updatedString != nil ? try DateFormatConverter.formatToDate(from: updatedString!) : nil
    }
}
