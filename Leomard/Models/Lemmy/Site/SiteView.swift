//
//  SiteView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation

struct SiteView: Codable {
    public let counts: SiteAggregates
    public let localSite: LocalSite
    public let localSiteRateLimit: LocalSiteRateLimit
    public let site: Site
}
