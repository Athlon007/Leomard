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

struct NoBodyPost: Codable {
    let auth: String
}

final class RequestHandler {
    public final let VERSION = "v3"


    public func makeApiRequest(host: String, request: String, method: HTTPMethod, body: Codable? = nil, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        var urlString = "\(host)/api/\(self.VERSION)\(request)"
    
        if !urlString.starts(with: "http") {
            urlString = "https://\(urlString)"
        }
        
        if SessionService().isSessionActive() && method == .get {
            let jwt = SessionService().load()?.loginResponse.jwt
            if !urlString.contains("?") {
                urlString += "?auth=\(jwt!)"
            } else {
                urlString += "&auth=\(jwt!)"
            }
        }
             
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Body is set? Include the Auth in body
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
                
                if SessionService().isSessionActive() {
                    jsonDictionary["auth"] = SessionService().load()?.loginResponse.jwt
                    jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
                }
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        } else if method != .get && SessionService().load()?.loginResponse.jwt != nil {
            // If no body is set, but the method is **NOT** GET, then add the "NoBodyPost" object with auth key.
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                let jsonData = try encoder.encode(NoBodyPost(auth: SessionService().load()!.loginResponse.jwt!))
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
