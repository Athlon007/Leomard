//
//  LoginService.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

class LoginService: Service {
    private let requestHandler: RequestHandler
    private let sessionService: SessionService
    
    private static let instancesList = "https://raw.githubusercontent.com/maltfield/awesome-lemmy-instances/main/awesome-lemmy-instances.csv"
    
    public init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func login(lemmyInstance: String, login: Login,Ca completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        self.requestHandler.makeApiRequest(host: lemmyInstance, request: "/user/login", method: .post, body: login) { result in
            switch (result) {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        let loginResponse: LoginResponse = try self.decode(type: LoginResponse.self, data: data)
                        completion(.success(loginResponse))
                    } catch {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getLemmyInstances(completion: @escaping (Result<[LemmyInstance], Error>) -> Void) {
        guard let url = URL(string: LoginService.instancesList) else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                
                completion(.failure(URLError.init(.badURL)))
                return
            }
            
            if let csvString = String(data: data, encoding: .utf8) {
                let csvRows = csvString.components(separatedBy: "\n").map { $0.components(separatedBy: ",")}
                
                var instances: [LemmyInstance] = []
                
                for row in csvRows {
                    if csvRows.first == row {
                        // First is just the header.
                        continue
                    }
   
                    let nameAndUrl = row[0]
                    if nameAndUrl == "" {
                        continue
                    }
                    
                    let federated = row[3]
                    let users = row[6]
                    let blockedBy = row[8]
                    let upTime = row[9]
                    
                    // Instance must be federated and not NSFW.
                    if federated != "Yes" {
                        continue
                    }
                    
                    // Instance must have 500 or more users
                    if Int(users)! < 500 {
                        continue
                    }
                    
                    // Instance cannot be blocked by more than 10 other instances.
                    if Int(blockedBy)! > 10 {
                        continue
                    }
                    
                    // Uptime must be larger than 95%
                    if Int(upTime.replacingOccurrences(of: "%", with: ""))! < 95 {
                        continue
                    }        
                
                    let name: String = nameAndUrl.split(separator: "]").map(String.init)[0].replacingOccurrences(of: "[", with: "")
                    let link: String = nameAndUrl.split(separator: "(").map(String.init)[1].replacingOccurrences(of: ")", with: "")
                    let lemmyInstance = LemmyInstance(name: name, url: link)
                    instances.append(lemmyInstance)
                }
                
                completion(.success(instances))
                return
            }
            completion(.failure(URLError.init(.badURL)))
        }.resume()
    }
}
