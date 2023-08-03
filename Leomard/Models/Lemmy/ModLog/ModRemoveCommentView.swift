//
//  ModRemoveCommentView.swift
//  Leomard
//
//  Created automatically by ts2swift 1.0 on 03/08/2023.
//

import Foundation

struct ModRemoveCommentView: Codable {
    let modRemoveComment: ModRemoveComment
    let moderator: Person?
    let comment: Comment
    let commenter: Person
    let post: Post
    let community: Community

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modRemoveComment = try container.decode(ModRemoveComment.self, forKey: .modRemoveComment)
        self.moderator = try container.decodeIfPresent(Person.self, forKey: .moderator)
        self.comment = try container.decode(Comment.self, forKey: .comment)
        self.commenter = try container.decode(Person.self, forKey: .commenter)
        self.post = try container.decode(Post.self, forKey: .post)
        self.community = try container.decode(Community.self, forKey: .community)
    }
}
