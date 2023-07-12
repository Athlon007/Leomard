//
//  PrivateMessageService.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation

class PrivateMessageService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    func getPrivateMessages(unreadOnly: Bool, page: Int, completion: @escaping(Result<PrivateMessagesResponse, Error>) -> Void) {
        var request = "/private_message/list?page=\(String(page))"
        if unreadOnly {
            request += "&unread_only=true"
        }
        
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
}
