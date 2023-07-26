//
//  PersonService.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation

class PersonService: Service {
    let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func getPersonDetails(person: Person, page: Int, savedOnly: Bool, sortType: SortType, completion: @escaping (Result<GetPersonDetailsResponse, Error>) -> Void) {
        var request = "/user?person_id=\(String(person.id))&page=\(String(page))&sort=\(String(describing: sortType))"
        if savedOnly {
            request += "&saved_only=true"
        }
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func block(person: Person, block: Bool, completion: @escaping (Result<BlockPersonResponse, Error>) -> Void) {
        let body = BlockPerson(block: block, personId: person.id)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/user/block", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func saveUserSettings(oldSettings: LocalUserView, bio: String, displayName: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let body = SaveUserSettings(
            bio: bio == oldSettings.person.bio ? nil : bio,
            displayName: displayName == oldSettings.person.displayName ? nil : displayName
        )  
        
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/user/save_user_settings", method: .put, body: body) { result in
            self.respond(result, completion)
        }
    }
}
