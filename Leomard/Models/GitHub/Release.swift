//
//  Release.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

struct Release: Codable {
    let htmlUrl: String
    let tagName: String
    let name: String
    let publishedAt: Date
    let assets: [ReleaseAsset]
    let body: String
}
