//
//  CaptchaResponse.swift
//  Leomard
//
//  Created automatically by ts2swift 1.2 on 11/08/2023.
//

import Foundation
import SwiftUI

struct CaptchaResponse: Codable, Hashable {
    let png: String
    let wav: String
    let uuid: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wav = try container.decode(String.self, forKey: .wav)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.png = try container.decode(String.self, forKey: .png)
    }
    
    func getImage() throws -> NSImage {
        if let data = Data(base64Encoded: png), let image = NSImage(data: data) {
            return image
        } else {
            throw LeomardExceptions.base64ToImageDecodingError("Failed converting base64 to an image. Possibly corrupted.")
        }
    }
}
