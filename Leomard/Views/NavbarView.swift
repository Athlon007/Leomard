//
//  NavbarView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

/// Sidebar root view for this app's `NavigationSplitView`.
struct NavbarView: View {
    let options: [Option]
    @Binding var profileOption: Option
    @Binding var currentSelection: Option
    @Binding var followedCommunities: [CommunityFollowerView]
    let contentView: ContentView
    @Binding var currentCommunity: Community?
    
    @Binding var unreadMessagesCount: Int
    @State var emptyCounter: Int = 0
    @State var followedVisible: Bool = true
    
    @State var addedLetters: [Character] = []
    
    @State var searchQuery: String = ""
    @State var searchVisible: Bool = false
    
    var body: some View {
        sidebarItems(options: options)
            .padding(.top, 24)
        followedCommunitiesList
            .frame(
                minHeight: 0,
                maxHeight: .infinity
            )
        userProfileItem
    }
    
    // MARK: -
    
    @ViewBuilder
    private func sidebarItems(options: [Option]) -> some View {
        VStack {
            ForEach(options, id: \.self) { option in
                NavbarItem(option: option, currentSelection: $currentSelection, contentView: contentView, currentCommunity: $currentCommunity, badgeCount: option.id == 1 ? $unreadMessagesCount : $emptyCounter)
            }
        }
        .NavBarItemContainer()
    }
    
    @ViewBuilder
    private var followedCommunitiesList: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    HStack(spacing: 14) {
                        Text("Followed")
                        Image(systemName: "v.circle")
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(followedVisible ? 180 : 0))
                    }
                    .onTapGesture {
                        followedVisible = !followedVisible
                    }
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchVisible ? Color(.linkColor) : .secondary)
                        .onTapGesture {
                            searchVisible = !searchVisible
                            if !searchVisible {
                                searchQuery = ""
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if searchVisible {
                    TextField("Search", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .frame(maxWidth: .infinity, alignment: .leading)
            List {
                if followedVisible {
                    ForEach(followedCommunities.sorted(by: {
                        UserPreferences.getInstance.preferDisplayNameCommunityFollowed ? $0.community.title < $1.community.title
                        : $0.community.name < $1.community.name
                    }).filter {
                        if searchQuery.count > 0 {
                            return $0.community.name.contains(searchQuery) || $0.community.title.contains(searchQuery)
                        } else {
                            return true
                        }
                    }
                            , id: \.self) { communityView in
                        if UserPreferences.getInstance.navbarShowLetterSeparators,
                           let firstChar =  UserPreferences.getInstance.preferDisplayNameCommunityFollowed ? communityView.community.title.first : communityView.community.name.first,
                           isFirstCommunityStartingWithThisChar(community: communityView.community) {
                            Text(String(firstChar.uppercased()))
                        }
                        NavbarCommunityItem(community: communityView.community, currentCommunity: $currentCommunity, contentView: contentView)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var userProfileItem: some View {
        VStack {
            NavbarItem(option: profileOption, currentSelection: $currentSelection, contentView: contentView, currentCommunity: $currentCommunity, badgeCount: $emptyCounter)
        }
        .NavBarItemContainer()
    }
    
    func isFirstCommunityStartingWithThisChar(community: Community) -> Bool {
        return followedCommunities.filter { $0.community.name.first!.uppercased() == community.name.first!.uppercased() }.first?.community == community
    }    
}
