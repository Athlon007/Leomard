//
//  PostService.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

class PostService: Service {
    let requestHandler: RequestHandler
    
    public init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func getAllPosts(page: Int, sortType: SortType, listingType: ListingType, completion: @escaping (Result<GetPostsResponse, Error>) -> Void) {
        let url = SessionStorage.getInstance.getLemmyInstance()
        self.requestHandler.makeApiRequest(host: url, request: "/post/list?page=\(String(page))&sort=\(sortType)&type_=\(listingType)", method: .get) { result in
            switch (result) {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        var responses = try self.decode(type: GetPostsResponse.self, data: data)
                        responses.posts.forEach { postView in
                            if postView.post.nsfw && !UserPreferences.getInstance.showNsfw ||
                                postView.post.nsfw && !UserPreferences.getInstance.showNsfwInFeed {
                                responses.posts = responses.posts.filter { $0 != postView}
                            }
                        }
                        completion(.success(responses))
                    } catch {
                        self.respondError(data, completion)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func setPostLike(post: Post, score: Int, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let body = CreatePostLike(postId: post.id, score: score)
        self.requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post/like", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func getPostForComment(comment: Comment, completion: @escaping (Result<GetPostResponse, Error>) -> Void) {
        let url = SessionStorage.getInstance.getLemmyInstance()
        self.requestHandler.makeApiRequest(host: url, request: "/post?comment_id=\(String(comment.id))", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func getPostsForCommunity(community: Community, page: Int, completion: @escaping (Result<GetPostsResponse, Error>) -> Void) {
        let url = SessionStorage.getInstance.getLemmyInstance()
        requestHandler.makeApiRequest(host: url, request: "/post/list?community_id=\(community.id)&page=\(String(page))", method: .get) { result in
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        var responses = try self.decode(type: GetPostsResponse.self, data: data)
                        responses.posts.forEach { postView in
                            if postView.post.nsfw && !UserPreferences.getInstance.showNsfw  {
                                responses.posts = responses.posts.filter { $0 != postView}
                            }
                        }
                        completion(.success(responses))
                    } catch {
                        self.respondError(data, completion)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func savePost(post: Post, save: Bool, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let url = SessionStorage.getInstance.getLemmyInstance()
        let body = SavePost(postId: post.id, save: save)
        requestHandler.makeApiRequest(host: url, request: "/post/save", method: .put, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func createPost(community: Community, name: String, body: String?, url: String?, nsfw: Bool?, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        
        let bodyText = body == "" ? nil : body
        let urlText = url == "" ? nil : url
        let nsfwBool = nsfw == nil || nsfw == false ? nil : nsfw
        
        let body = CreatePost(body: bodyText, communityId: community.id, honeypot: nil, languageId: nil, name: name, nsfw: nsfwBool, url: urlText)
        
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func deletePost(post: Post, deleted: Bool, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let body = DeletePost(postId: post.id, deleted: deleted)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post/delete", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func editPost(post: Post, name: String?, body: String?, url: String?, nsfw: Bool?, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let body = EditPost(postId: post.id, body: body == "" ? nil : body, honeypot: nil, languageId: nil, name: name == "" ? nil : name, nsfw: nsfw == nil || nsfw == false ? nil : nsfw, url: url == "" ? nil: url)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post", method: .put, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func report(post: Post, reason: String, completion: @escaping (Result<PostReportResponse, Error>) -> Void) {
        let body = CreatePostReport(postId: post.id, reason: reason)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post/report", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func feature(post: Post, featureType: PostFeatureType, featured: Bool, completion: @escaping(Result<PostResponse, Error>) -> Void) {
        let body = FeaturePost(featureType: String(describing: featureType), featured: featured, postId: post.id)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post/feature", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func markAsRead(post: Post, read: Bool, completion: @escaping(Result<PostResponse, Error>) -> Void) {
        if !SessionStorage.getInstance.isSessionActive() {
            completion(.failure(LeomardExceptions.notLoggedIn("You're not logged in.")))
            return
        }
        
        let body = MarkPostAsRead(postId: post.id, read: read)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/post/mark_as_read", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
}
