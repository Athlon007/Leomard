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
        self.requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/site", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func getSite(url: String, completion: @escaping (Result<GetSiteResponse, Error>) -> Void) {
        self.requestHandler.makeApiRequest(host: url, request: "/site", method: .get, noAuth: true) { result in
            self.respond(result, completion)
        }
    }
}
