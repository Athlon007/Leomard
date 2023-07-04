//
//  GetCommentsResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct GetCommentsResponse: Codable {
    public var comments: [CommentView]
}
