//
//  GithubService.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation

class GithubService: Service {
    private let requestHandler: RequestHandler
    
    private static let gitHubApi = "https://api.github.com"
    private static let listReleasesRequest = "/repos/Athlon007/Leomard/releases"
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    func getReleases(completion: @escaping(Result<[Release], Error>) -> Void) {
        requestHandler.makeApiRequest(host: GithubService.gitHubApi, request: GithubService.listReleasesRequest, method: .get) { result in
            self.respond(result, completion)
        }
    }
}
