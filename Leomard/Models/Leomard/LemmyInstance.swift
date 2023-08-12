//
//  LemmyInstance.swift
//  Leomard
//
//  Created by Konrad Figura on 09/07/2023.
//

import Foundation

struct LemmyInstance: Hashable {
    let name: String
    let url: String
    var site: GetSiteResponse?
}
