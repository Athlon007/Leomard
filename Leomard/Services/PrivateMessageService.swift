//
//  PrivateMessageService.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

class PrivateMessageService: Service {
    let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    func getPrivateMessages(unreadOnly: Bool, page: Int, completion: @escaping(Result<PrivateMessagesResponse, Error>) -> Void) {
        var request = "/private_message/list?page=\(String(page))"
        if unreadOnly {
            request += "&unread_only=true"
        }
        
        requestHandler.makeApiRequest(host: SessionService().getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    func sendPrivateMessage(content: String, recipient: Person, completion: @escaping(Result<PrivateMessageResponse, Error>) -> Void) {
        let body = CreatePrivateMessage(content: content, recipientId: recipient.id)
        requestHandler.makeApiRequest(host: SessionService().getLemmyInstance(), request: "/private_message", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    func markAsRead(privateMessage: PrivateMessage, read: Bool, completion: @escaping (Result<PrivateMessageResponse, Error>) -> Void) {
        let body = MarkPrivateMessageAsRead(privateMessageId: privateMessage.id, read: read)
        requestHandler.makeApiRequest(host: SessionService().getLemmyInstance(), request: "/private_message/mark_as_read", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
}
