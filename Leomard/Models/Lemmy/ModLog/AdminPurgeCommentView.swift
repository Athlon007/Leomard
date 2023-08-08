//
//  AdminPurgeCommentView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 04/08/2023.
//

import Foundation

struct AdminPurgeCommentView: Codable, Hashable {
    let adminPurgeComment: AdminPurgeComment
    let admin: Person?
    let post: Post

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.adminPurgeComment = try container.decode(AdminPurgeComment.self, forKey: .adminPurgeComment)
        self.admin = try container.decodeIfPresent(Person.self, forKey: .admin)
        self.post = try container.decode(Post.self, forKey: .post)
    }
}
