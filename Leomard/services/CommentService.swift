//
//  CommentService.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

class CommentService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    public init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    private func getPathDepth(path: String) -> Int {
        let dotCount = path.reduce(0) { (count, character) -> Int in
            if character == "." {
                return count + 1
            } else {
                return count
            }
        }
        return dotCount - 1
    }
    
    public func getAllComments(post: Post, page: Int, sortType: CommentSortType, completion: @escaping (Result<GetCommentsResponse, Error>) -> Void) {
        let postId = post.id
        let host = self.sessionService.getLemmyInstance()
        self.requestHandler.makeApiRequest(host: host, request: "/comment/list?post_id=\(String(postId))&sort=\(String(describing: sortType))&page=\(String(page))", method: .get) { result in
            switch result {
            case .success(let response):
                do {
                    var getCommentResponse = try self.decode(type: GetCommentsResponse.self, data: response.data!)
                    if page > 1 && getCommentResponse.comments.count > 0 {
                        getCommentResponse.comments.removeFirst()
                    }
                    getCommentResponse.comments.forEach { commentView in
                        if self.getPathDepth(path: commentView.comment.path) > 0 {
                            getCommentResponse.comments = getCommentResponse.comments.filter { $0 != commentView}
                        }
                    }
                    
                    completion(.success(getCommentResponse))
                } catch {
                    self.respondError(response.data!, completion)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getCommentsForCommunity(community: Community, page: Int, completion: @escaping (Result<GetCommentsResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        requestHandler.makeApiRequest(host: host, request: "/comment/list?community_id=\(String(community.id))", method: .get) { result in
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.data {
                    do {
                        var response = try self.decode(type: GetCommentsResponse.self, data: data)
                        if page > 1 && response.comments.count > 0 {
                            response.comments.removeFirst()
                        }
                        
                        completion(.success(response))
                    } catch {
                        self.respondError(data, completion)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getSubcomments(comment: Comment, page: Int, level: Int, completion: @escaping (Result<GetCommentsResponse, Error>) -> Void) {
        let commentId = comment.id
        let host = self.sessionService.getLemmyInstance()
        self.requestHandler.makeApiRequest(host: host, request: "/comment/list?parent_id=\(String(commentId))&sort=\(CommentSortType.top)&page=\(String(page))", method: .get) { result in
            switch result {
            case .success(let response):
                do {
                    var getCommentResponse = try self.decode(type: GetCommentsResponse.self, data: response.data!)
                    // Remove first comment (self).
                    getCommentResponse.comments.forEach { commentView in
                        if self.getPathDepth(path: commentView.comment.path) != level {
                            getCommentResponse.comments = getCommentResponse.comments.filter { $0 != commentView}
                        }
                    }
                    completion(.success(getCommentResponse))
                } catch {
                    self.respondError(response.data!, completion)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func setCommentLike(comment: Comment, score: Int, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        let body = CreateCommentLike(commentId: comment.id, score: score)
        self.requestHandler.makeApiRequest(host: self.sessionService.getLemmyInstance(), request: "/comment/like", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func createComment(content: String, post: Post, parent: Comment? = nil, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        let body = CreateComment(content: content, formId: nil, languageId: nil, parentId: parent?.id, postId: post.id)
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/comment", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func deleteComment(comment: Comment, completion: @escaping (Result<Bool, Error>) -> Void) {
        let body = DeleteComment(commentId: comment.id, deleted: true)
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/comment/delete", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func updateComment(comment: Comment, content: String, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        let body = EditComment(commentId: comment.id, content: content, formId: nil, languageId: nil)
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/comment", method: .put, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func saveComment(comment: Comment, save: Bool, completion: @escaping (Result<CommentResponse, Error>) -> Void) {
        let url = sessionService.getLemmyInstance()
        let body = SaveComment(commentId: comment.id, save: save)
        requestHandler.makeApiRequest(host: url, request: "/comment/save", method: .put, body: body) { result in
            self.respond(result, completion)
        }
    }
}
