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
        var searchQuery = query.replacingOccurrences(of: " ", with: "%20")
        
        var instanceSearch: Bool = false
        var searchedInstance: String = ""
        
        if searchQuery.containsAny("@", "!") {
            instanceSearch = true
            searchedInstance = searchQuery.components(separatedBy: "@").last!
            searchQuery = searchQuery.dropFirst().components(separatedBy: "@").first!
        }
        
        var request = "/search?q=\(searchQuery)&type_=\(String(describing: searchType))&page=\(String(page))"
        if searchType == .communities {
            request += "&sort=TopAll"
        }
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: request, method: .get) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        var response = try self.decode(type: SearchResponse.self, data: data)
                        response.posts.forEach { postView in
                            if postView.post.nsfw && !UserPreferences.getInstance.showNsfw
                                || UserPreferences.isBlockedInstance(postView.post.apId) {
                                response.posts = response.posts.filter { $0 != postView }
                            }
                        }
                        
                        response.communities.forEach { communityView in
                            if (communityView.community.nsfw && !UserPreferences.getInstance.showNsfw)
                                || (instanceSearch && !communityView.community.actorId.contains(searchedInstance))
                                || (instanceSearch && communityView.community.name != searchQuery.lowercased())
                                || UserPreferences.isBlockedInstance(communityView.community.actorId) {
                                response.communities = response.communities.filter {
                                    $0 != communityView
                                }
                            }
                        }
                        
                        response.comments.forEach { commentView in
                            if commentView.post.nsfw && !UserPreferences.getInstance.showNsfw
                                || UserPreferences.isBlockedInstance(commentView.community.actorId){
                                response.comments = response.comments.filter { $0 != commentView }
                            }
                        }
                        
                        if instanceSearch {
                            response.users = response.users.filter { $0.person.actorId.contains(searchedInstance) }
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
    
    public func search(community: Community, query: String, searchType: SearchType, page: Int, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        let searchQuery = query.replacingOccurrences(of: " ", with: "%20")
        let request = "/search?q=\(searchQuery)&type_=\(String(describing: searchType))&page=\(String(page))&community_id=\(community.id)"
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: request, method: .get) { result in
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
