//
//  GetModlogResponse.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct GetModlogResponse: Codable {
    let removedPosts: [ModRemovePostView]
    let lockedPosts: [ModLockPostView]
    let featuredPosts: [ModFeaturePostView]
    let removedComments: [ModRemoveCommentView]
    let removedCommunities: [ModRemoveCommunityView]
    let bannedFromCommunity: [ModBanFromCommunityView]
    let banned: [ModBanView]
    let addedToCommunity: [ModAddCommunityView]
    let transferredToCommunity: [ModTransferCommunityView]
    let added: [ModAddView]
    let adminPurgedPersons: [AdminPurgePersonView]
    let adminPurgedCommunities: [AdminPurgeCommunityView]
    let adminPurgedPosts: [AdminPurgePostView]
    let adminPurgedComments: [AdminPurgeCommentView]
    let hiddenCommunities: [ModHideCommunityView]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.removedPosts = try container.decode([ModRemovePostView].self, forKey: .removedPosts)
        self.lockedPosts = try container.decode([ModLockPostView].self, forKey: .lockedPosts)
        self.featuredPosts = try container.decode([ModFeaturePostView].self, forKey: .featuredPosts)
        self.removedComments = try container.decode([ModRemoveCommentView].self, forKey: .removedComments)
        self.removedCommunities = try container.decode([ModRemoveCommunityView].self, forKey: .removedCommunities)
        self.bannedFromCommunity = try container.decode([ModBanFromCommunityView].self, forKey: .bannedFromCommunity)
        self.banned = try container.decode([ModBanView].self, forKey: .banned)
        self.addedToCommunity = try container.decode([ModAddCommunityView].self, forKey: .addedToCommunity)
        self.transferredToCommunity = try container.decode([ModTransferCommunityView].self, forKey: .transferredToCommunity)
        self.added = try container.decode([ModAddView].self, forKey: .added)
        self.adminPurgedPersons = try container.decode([AdminPurgePersonView].self, forKey: .adminPurgedPersons)
        self.adminPurgedCommunities = try container.decode([AdminPurgeCommunityView].self, forKey: .adminPurgedCommunities)
        self.adminPurgedPosts = try container.decode([AdminPurgePostView].self, forKey: .adminPurgedPosts)
        self.adminPurgedComments = try container.decode([AdminPurgeCommentView].self, forKey: .adminPurgedComments)
        self.hiddenCommunities = try container.decode([ModHideCommunityView].self, forKey: .hiddenCommunities)
    }
}
