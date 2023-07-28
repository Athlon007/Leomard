//
//  UserPreferences.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

final class UserPreferences: ObservableObject {
    @State private static var instance = UserPreferences()
    @ObservedObject public static var getInstance = UserPreferences.instance
    
    private init() {}
    
    // MARK: - NSFW
    @AppStorage("show_nsfw", store: .standard) var showNsfw: Bool = false
    @AppStorage("show_nsfw_in_feed", store: .standard) var showNsfwInFeed: Bool = false
    @AppStorage("blur_nsfw", store: .standard) var blurNsfw: Bool = true
    
    // MARK: - Sort & List Type Settings
    @AppStorage("post_sort_method", store: .standard) var postSortMethod: SortType = .hot
    @AppStorage("listing_type", store: .standard) var listType: ListingType = .all
    @AppStorage("comment_sort_method", store: .standard) var commentSortMethod: CommentSortType = .top
    
    // MARK: - Notifs
    @AppStorage("check_notifs_every", store: .standard) var checkNotifsEverySeconds: Int = 60
    @AppStorage("unreadonly_when_opening_inbox", store: .standard) var unreadonlyWhenOpeningInbox: Bool = true
    @AppStorage("profile_sort_method", store: .standard) var profileSortMethod: SortType = .new
    @AppStorage("check_for_update_frequency", store: .standard) var checkForUpdateFrequency: UpdateFrequency = .onceADay
    // MARK: - Mark as Read Stuff
    @AppStorage("mark_post_as_read_on_open", store: .standard) var markPostAsReadOnOpen: Bool = true
    @AppStorage("mark_post_as_read_on_vote", store: .standard) var markPostAsReadOnVote: Bool = true
    @AppStorage("hide_read_posts", store: .standard) var hideReadPosts: Bool = false
    
    // MARK: - Not in Preferences.
    @AppStorage("skipped_update_version", store: .standard) var skippedUpdateVersion: String = ""
    @AppStorage("last_update_check_date", store: .standard) var lastUpdateCheckDate: Date = Date()
    
    // MARK: - Blocked instances
    @AppStorage("blocked_instances", store: .standard) var blockedInstances: String = ""
    
    // MARK: - Post View
    @AppStorage("use_post_compact_view", store: .standard) var usePostCompactView: Bool = false
    
    // MARK: - Navbar
    @AppStorage("navbar_show_letter_separators", store: .standard) var navbarShowLetterSeparators: Bool = false
    
    let sortTypes: [SortType] = [ .topHour, .topDay, .topMonth, .topYear, .hot, .active, .new, .mostComments ]
    let profileSortTypes: [SortType] = [ .topWeek, .topMonth, .topYear, .hot, .active, .new, .mostComments, .old ]
    
    static func isBlockedInstance(_ url: String) -> Bool {
        for instance in self.getInstance.blockedInstances.components(separatedBy: ",") {
            if url.contains(instance.replacingOccurrences(of: " ", with: "")) {
                return true
            }
        }
        
        return false
    }
}
