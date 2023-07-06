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
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        let response = try self.decode(type: GetCommunityResponse.self, data: data)
                        completion(.success(response))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func followCommunity(community: Community, follow: Bool, completion: @escaping (Result<CommunityResponse, Error>) -> Void) {
        let host = sessionService.getLemmyInstance()
        let followCommunity = FollowCommunity(communityId: community.id, follow: follow)
        requestHandler.makeApiRequest(host: host, request: "/community/follow", method: .post, body: followCommunity) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        let response = try self.decode(type: CommunityResponse.self, data: data)
                        completion(.success(response))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
