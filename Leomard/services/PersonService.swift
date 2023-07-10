//
//  PersonService.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

class PersonService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func getPersonDetails(person: Person, page: Int, savedOnly: Bool, completion: @escaping (Result<GetPersonDetailsResponse, Error>) -> Void) {
        var request = "/user?person_id=\(String(person.id))&page=\(String(page))"
        if savedOnly {
            request += "&saved_only=true"
        }
        requestHandler.makeApiRequest(host: sessionService.getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
}
