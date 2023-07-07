//
//  ApiHandler.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct APIResponse {
    let statusCode: Int
    let data: Data?
}

final class RequestHandler {
    public final let VERSION = "v3"
    
    let sessionService: SessionService
    
    public init(sessionService: SessionService) {
        self.sessionService = sessionService
    }

    public func makeApiRequest(host: String, request: String, method: HTTPMethod, body: Codable? = nil, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        var urlString = "\(host)/api/\(self.VERSION)\(request)"
    
        if !urlString.starts(with: "http") {
            urlString = "https://\(urlString)"
        }
        
        if sessionService.isSessionActive() {
            let jwt = sessionService.load()?.loginResponse.jwt
            if !urlString.contains("?") {
                urlString += "?auth=\(jwt!)"
            } else {
                urlString += "&auth=\(jwt!)"
            }
        }
        
        print(urlString)
             
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Body is set? Include it.
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                var jsonData = try encoder.encode(body)
                
                // Add the authentication to body, as it's needed for POSTs.
                // To do that, we first must decode back the object, add "auth" key, and re-encode it.
                guard var jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON data."])
                        completion(.failure(error))
                        return
                    }
                
                jsonDictionary["auth"] = sessionService.load()?.loginResponse.jwt
                jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
    
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            let statusCode = httpResponse.statusCode
            let apiResponse = APIResponse(statusCode: statusCode, data: data)
            completion(.success(apiResponse))
        }).resume()
    }
}
