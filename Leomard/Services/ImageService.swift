//
//  ImageService.swift
//  Leomard
//
//  Created by Konrad Figura on 21/07/2023.
//

import Foundation

class ImageService: Service {
    private let requestHandler: RequestHandler
    private let maxFileSize: Int = 10 // Megabytes
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func uploadImage(url: URL, completion: @escaping (Result<ImgurImageUploadResponse, Error>) -> Void) {
        // Check file size
        if !isFileSizeOk(url: url) {
            completion(.failure(LeomardExceptions.fileSizeTooLarge("File size is too large (max: 10 MB)")))
            return
        }
        
        var base64 = ""
        do {
            base64 = try self.convertFileToBase64(url: url)
        } catch {
            completion(.failure(error))
            return
        }
        
        let apiKey = Bundle.main.infoDictionary?["IMGUR_KEY"] as? String
        if apiKey == nil || apiKey == "" || apiKey == "api_key_goes_here" {
            completion(.failure(LeomardExceptions.missingApiKey("Imgur API Key is missing")))
            return
        }
        
        let body = ImgurImageUploadForm(image: base64)
        let headers: [String:String] = [
            "Authorization": "Client-Id \(apiKey!)"
        ]
        
        requestHandler.makeApiRequest(host: "https://api.imgur.com", request: "/3/image", method: .post, headers: headers, body: body) {
            result in
            self.respond(result, completion)
        }
    }
    
    private func convertFileToBase64(url: URL) throws -> String {
        let data = try Data.init(contentsOf: url)
        let stream: String = data.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return stream
    }
    
    private func isFileSizeOk(url: URL) -> Bool {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.absoluteString.replacingOccurrences(of: "file://", with: ""))
        
        if attributes != nil {
            let size = attributes![.size] as? UInt64 ?? UInt64(0)
            return size < maxFileSize * 1000000
        }
        
        return false
    }
}
