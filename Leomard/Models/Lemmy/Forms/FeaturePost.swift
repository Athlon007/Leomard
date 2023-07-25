//
//  FeaturePost.swift
//  Leomard
//
//  Created by Konrad Figura on 25/07/2023.
//

import Foundation

struct FeaturePost: Codable {
    let featureType: PostFeatureType
    let featured: Bool
    let postId: Int
}
