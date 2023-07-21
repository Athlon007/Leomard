//
//  ImageService.swift
//  Leomard
//
//  Created by Konrad Figura on 21/07/2023.
//

import Foundation

class ImageService: Service {
    private let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func uploadImage(url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        var base64 = ""
        do {
            base64 = try self.convertFileToBase64(url: url)
        } catch {
            completion(.failure(error))
            return
        }
        
        print(base64)
    }
    
    private func convertFileToBase64(url: URL) throws -> String {
        let data = try Data.init(contentsOf: url)
        let stream: String = data.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return stream
    }
}
