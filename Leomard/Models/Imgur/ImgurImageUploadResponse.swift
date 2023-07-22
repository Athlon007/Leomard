//
//  ImgurImageUploadResponse.swift
//  Leomard
//
//  Created by Konrad Figura on 21/07/2023.
//

import Foundation

struct ImgurImageUploadResponse: Codable {
    let data: ImgurImage
    let success: Bool
    let status: Int
}
