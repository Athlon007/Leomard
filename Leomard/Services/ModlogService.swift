//
//  ModlogService.swift
//  Leomard
//
//  Created by Konrad Figura on 04/08/2023.
//

import Foundation

class ModlogService: Service {
    private let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    func getModlog(community: Community, page: Int, completion: @escaping (Result<GetModlogResponse, Error>) -> Void) {
        let request = "/modlog?community_id=\(community.id)&page=\(page)"
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: request, method: .get) { result in
            self.respond(result, completion)
        }
    }
}
