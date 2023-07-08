//
//  SearchResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

struct SearchResponse: Codable {
    public var comments: [CommentView]
    public var communities: [CommunityView]
    public var posts: [PostView]
    public let type_: SearchType
    public var users: [PersonView]
    
    init() {
        comments = []
        communities = []
        posts = []
        type_ = .all
        users = []
    }
}
