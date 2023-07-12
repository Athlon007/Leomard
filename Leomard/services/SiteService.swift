//
//  SiteService.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

class SiteService: Service {
    private let requestHandler: RequestHandler
    
    public init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func getSite(Ca completion: @escaping (Result<GetSiteResponse, Error>) -> Void) {
        self.requestHandler.makeApiRequest(host: SessionService().getLemmyInstance(), request: "/site", method: .get) { result in
            self.respond(result, completion)
        }
    }
}
