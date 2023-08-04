//
//  ModLockPostView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct ModLockPostView: Codable, Hashable {
    let modLockPost: ModLockPost
    let moderator: Person?
    let post: Post
    let community: Community

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modLockPost = try container.decode(ModLockPost.self, forKey: .modLockPost)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.post = try container.decode(Post.self, forKey: .post)
        self.community = try container.decode(Community.self, forKey: .community)
    }
}
