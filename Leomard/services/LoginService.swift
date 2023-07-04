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
}
