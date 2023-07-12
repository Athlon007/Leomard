//
//  RepliesService.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

class RepliesService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    func getReplies(unreadOnly: Bool, sortType: CommentSortType, page: Int, completion: @escaping(Result<GetRepliesResponse, Error>) -> Void) {
        var request = "/user/replies?page=\(String(page))"
        if unreadOnly {
            request += "&unread_only=true"
        }
        request += "&sort=\(String(describing: sortType))"
        
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    func getCounts(completion: @escaping(Result<GetUnreadCountResponse, Error>) -> Void) {
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/user/unread_count", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    func markAsRead(commentReply: CommentReply, read: Bool, completion: @escaping(Result<CommentReplyResponse, Error>) -> Void) {
        let body = MarkCommentReplyAsRead(commentReplyId: commentReply.id, read: read)
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: "/comment/mark_as_read", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
}
