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
    
    public func getSiteIcon(url: String, completion: @escaping (Result<URL, Error>) -> Void) {
        requestHandler.makeApiRequest(host: url, request: "/site", method: .get, noAuth: true) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        let response = try self.decode(type: GetSiteResponse.self, data: data)
                        if let icon = response.siteView.site.icon, let url = URL(string: icon) {
                            completion(.success(url))
                            return
                        }
                    }
                    completion(.failure(LeomardExceptions.unableToGetIcon("Cannot get icon for \(url)")))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
