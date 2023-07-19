//
//  MyUserInfo.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct MyUserInfo: Codable {
    public let communityBlocks: [CommunityBlockView]
    public let discussionLanguages: [Int]
    public let follows: [CommunityFollowerView]
    public let localUserView: LocalUserView
    public let moderates: [CommunityModeratorView]
    public var personBlocks: [PersonBlockView]
    
}
