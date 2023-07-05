//
//  GetPersonDetailsResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

struct GetPersonDetailsResponse: Codable {
    public var comments: [CommentView]
    public let moderates: [CommunityModeratorView]
    public let personView: PersonView
    public var posts: [PostView]
}
