//
//  SearchService.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation

class SearchService: Service {
    let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func search(query: String, searchType: SearchType, page: Int, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        var host = SessionService().getLemmyInstance()
        var searchQuery = query.replacingOccurrences(of: " ", with: "%20")
        
        // Experimental cross-instance search.
        if UserPreferences.getInstance.experimentXInstanceSearch && searchQuery.range(of: "@[\\w-]+\\.[\\w-]+$", options: .regularExpression, range: nil, locale: nil) != nil {
            host = searchQuery.components(separatedBy: "@").last!
            searchQuery = searchQuery.replacingOccurrences(of: "@\(host)", with: "")
        }
        
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
                            if postView.post.nsfw && !UserPreferences.getInstance.showNsfw  {
                                response.posts = response.posts.filter { $0 != postView }
                            }
                        }
                        
                        response.communities.forEach { communityView in
                            if communityView.community.nsfw && !UserPreferences.getInstance.showNsfw {
                                response.communities = response.communities.filter { $0 != communityView }
                            }
                        }
                        
                        response.comments.forEach { commentView in
                            if commentView.post.nsfw && !UserPreferences.getInstance.showNsfw  {
                                response.comments = response.comments.filter { $0 != commentView }
                            }
                        }
                        
                        completion(.success(response))
                    }
                } catch {
                    self.respondError(apiResponse.data!, completion)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
