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
    let userPreferences: UserPreferences = UserPreferences()
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func search(query: String, searchType: SearchType, page: Int, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        let searchQuery = query.replacingOccurrences(of: " ", with: "%20")
        var request = "/search?q=\(searchQuery)&type_=\(String(describing: searchType))&page=\(String(page))"
        if searchType == .communities {
            request += "&sort=TopAll"
        }
        requestHandler.makeApiRequest(host: host, request: request, method: .get) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        var response = try self.decode(type: SearchResponse.self, data: data)
                        response.posts.forEach { postView in
                            if postView.post.nsfw && !self.userPreferences.showNsfw  {
                                response.posts = response.posts.filter { $0 != postView }
                            }
                        }
                        
                        response.communities.forEach { communityView in
                            if communityView.community.nsfw && !self.userPreferences.showNsfw {
                                response.communities = response.communities.filter { $0 != communityView }
                            }
                        }
                        
                        response.comments.forEach { commentView in
                            if commentView.post.nsfw && !self.userPreferences.showNsfw  {
                                response.comments = response.comments.filter { $0 != commentView }
                            }
                        }
                        
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
