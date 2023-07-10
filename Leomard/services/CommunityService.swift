//
//  CommunityService.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation

class CommunityService: Service {
    let requestHandler: RequestHandler
    let sessionService: SessionService
    
    init(requestHandler: RequestHandler, sessionService: SessionService) {
        self.requestHandler = requestHandler
        self.sessionService = sessionService
    }
    
    public func getCommunity(id: Int, completion: @escaping (Result<GetCommunityResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        requestHandler.makeApiRequest(host: host, request: "/community?id=\(id)", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func followCommunity(community: Community, follow: Bool, completion: @escaping (Result<CommunityResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        let followCommunity = FollowCommunity(communityId: community.id, follow: follow)
        requestHandler.makeApiRequest(host: host, request: "/community/follow", method: .post, body: followCommunity) { result in
            self.respond(result, completion)
        }
    }
}
