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
            self.respond(result, completion)
        }
    }
}
