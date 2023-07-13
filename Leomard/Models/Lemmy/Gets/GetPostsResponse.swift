//
//  GetPostsResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct GetPostsResponse: Hashable, Codable
{
    public var posts: [PostView]
    
    init() {
        posts = []
    }
}

