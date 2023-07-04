//
//  PostService.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

class PostService: Service {
    let requestHandler: RequestHandler
    public let sessionService: SessionService
    
    public init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func getAllPosts(page: Int, sortType: SortType, listingType: ListingType, completion: @escaping (Result<GetPostsResponse, Error>) -> Void) {
        let url = self.sessionService.getLemmyInstance()
        self.requestHandler.makeApiRequest(host: url, request: "/post/list?page=\(String(page))&sort=\(sortType)&type_=\(listingType)", method: .get) { result in
            switch (result) {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        var responses = try self.decode(type: GetPostsResponse.self, data: data)
                        responses.posts.forEach { postView in
                            if postView.post.nsfw {
                                responses.posts = responses.posts.filter { $0 != postView}
                            }
                        }
                        completion(.success(responses))
                    } catch {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func setPostLike(post: Post, score: Int, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let body = CreatePostLike(postId: post.id, score: score)
        self.requestHandler.makeApiRequest(host: self.sessionService.getLemmyInstance(), request: "/post/like", method: .post, body: body) { result in
            switch (result) {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        let response = try self.decode(type: PostResponse.self, data: data)
                        completion(.success(response))
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
