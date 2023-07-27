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
        let host = SessionStorage.getInstance.getLemmyInstance()
        requestHandler.makeApiRequest(host: host, request: "/community?id=\(id)", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func followCommunity(community: Community, follow: Bool, completion: @escaping (Result<CommunityResponse, Error>) -> Void) {
        let host = SessionStorage.getInstance.getLemmyInstance()
        let followCommunity = FollowCommunity(communityId: community.id, follow: follow)
        requestHandler.makeApiRequest(host: host, request: "/community/follow", method: .post, body: followCommunity) { result in
            self.respond(result, completion)
        }
    }
    
    public func getCommunityFromLink(link: String, completion: @escaping (Result<GetCommunityResponse, Error>) -> Void) {
        let community = link.components(separatedBy: "@")[0].replacingOccurrences(of: "!", with: "")
        let host = link.components(separatedBy: "@")[1]
        requestHandler.makeApiRequest(host: host, request: "/community?name=\(community)", method: .get) { result in
            self.respond(result, completion)
        }
    }
    
    public func block(community: Community, block: Bool, completion: @escaping (Result<BlockCommunityResponse, Error>) -> Void) {
        let body = BlockCommunity(block: block, communityId: community.id)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/community/block", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func getCommunities(page: Int, showNsfw: Bool, sortType: SortType, listingType: ListingType, completion: @escaping (Result<ListCommunitiesResponse, Error>) -> Void) {
        let nsfw = !UserPreferences.getInstance.showNsfw ? false : showNsfw
        let request = "/community/list?page=\(page)&show_nsfw=\(nsfw)&sort=\(String(describing: sortType))&type_=\(String(describing: listingType))"
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: request, method: .get) { result in
            switch result {
            case .success(let apiResponse):
                do {
                    if let data = apiResponse.data {
                        var response = try self.decode(type: ListCommunitiesResponse.self, data: data)
                        response.communities = response.communities.filter { !UserPreferences.isBlockedInstance($0.community.actorId) }
                        completion(.success(response))
                    }
                } catch {
                    
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func remove(community: Community, removed: Bool, completion: @escaping((Result<CommunityResponse, Error>)) -> Void) {
        let body = RemoveCommunity(communityId: community.id, removed: removed)
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/community/remove", method: .post, body: body) { result in
            self.respond(result, completion)
        }
    }
    
    public func edit(community: Community, displayName: String, description: String, nsfw: Bool, postingRestrictedToMods: Bool, completion: @escaping (Result<CommunityResponse, Error>) -> Void) {
        let body = EditCommunity(
            communityId: community.id,
            description: description == community.description ? nil : description,
            nsfw: nsfw == community.nsfw ? nil : nsfw,
            postingRestrictedToMods: postingRestrictedToMods == community.postingRestrictedToMods ? nil : postingRestrictedToMods,
            title: displayName == community.title ? nil : displayName
        )
        
        requestHandler.makeApiRequest(host: SessionStorage.getInstance.getLemmyInstance(), request: "/community", method: .put) { result in
            self.respond(result, completion)
        }
    }
}
