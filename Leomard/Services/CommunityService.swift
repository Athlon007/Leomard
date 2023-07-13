//
//  CommunityService.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation

class CommunityService: Service {
    let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func getCommunity(id: Int, completion: @escaping (Result<GetCommunityResponse, Error>) -> Void) {
        let host = SessionService().getLemmyInstance()
        requestHandler.makeApiRequest(host: host, request: "/community?id=\(id)", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func followCommunity(community: Community, follow: Bool, completion: @escaping (Result<CommunityResponse, Error>) -> Void) {
        let host = SessionService().getLemmyInstance()
        let followCommunity = FollowCommunity(communityId: community.id, follow: follow)
        requestHandler.makeApiRequest(host: host, request: "/community/follow", method: .post, body: followCommunity) { result in
            self.respond(result, completion)
        }
    }
}
