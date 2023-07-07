//
//  SearchService.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

class SearchService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func search(query: String, searchType: SearchType, page: Int, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        let searchQuery = query.replacingOccurrences(of: " ", with: "%20")
        requestHandler.makeApiRequest(host: host, request: "/search?q=\(searchQuery)&type_=\(String(describing: searchType))&page=\(String(page))", method: .get) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        let response = try self.decode(type: SearchResponse.self, data: data)
                        completion(.success(response))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
