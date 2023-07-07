//
//  SearchResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

struct SearchResponse: Codable {
    public let comments: [CommentView]
    public let communities: [CommentView]
    public let posts: [PostView]
    public let type: [SearchType]
    public let users: [PersonView]
}
