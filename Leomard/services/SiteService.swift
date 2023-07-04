//
//  SiteService.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

class SiteService: Service {
    private let requestHandler: RequestHandler
    private let sessionService: SessionService
    
    public init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func getSite(Ca completion: @escaping (Result<GetSiteResponse, Error>) -> Void) {
        self.requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/site", method: .get) { result in
            switch (result) {
            case.success(let response):
                if response.data != nil {
                    do {
                        let getSiteResponse = try self.decode(type: GetSiteResponse.self, data: response.data!)
                        completion(.success(getSiteResponse))
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
