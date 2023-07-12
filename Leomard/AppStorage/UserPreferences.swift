//
//  UserPreferences.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

final class UserPreferences: ObservableObject {
    @AppStorage("show_nsfw", store: .standard) var showNsfw: Bool = false
    @AppStorage("blur_nsfw", store: .standard) var blurNsfw: Bool = true
    @AppStorage("post_sort_method", store: .standard) var postSortMethod: SortType = .hot
    @AppStorage("listing_type", store: .standard) var listType: ListingType = .all
    @AppStorage("comment_sort_method", store: .standard) var commentSortMethod: CommentSortType = .top
    @AppStorage("check_notifs_every", store: .standard) var checkNotifsEverySeconds: Int = 60
    
    @AppStorage("experiment_x_instance_search", store: .standard) var experimentXInstanceSearch: Bool = false
    
    let sortTypes: [SortType] = [ .topHour, .topDay, .topMonth, .topYear, .hot, .active, .new, .mostComments ]
}