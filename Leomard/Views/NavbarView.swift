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
        List {
            HStack(spacing: 14) {
                Text("Followed")
                Image(systemName: "v.circle")
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(followedVisible ? 180 : 0))
            }
            .onTapGesture {
                followedVisible = !followedVisible
            }
            if followedVisible {
                ForEach(followedCommunities, id: \.self) { communityView in
                    NavbarCommunityItem(community: communityView.community, currentCommunity: $currentCommunity, contentView: contentView)
                }
            }
        }
    }
    
    @ViewBuilder
    private var userProfileItem: some View {
        VStack {
            NavbarItem(option: profileOption, currentSelection: $currentSelection, contentView: contentView, currentCommunity: $currentCommunity, badgeCount: $emptyCounter)
        }
        .NavBarItemContainer()
    }
}
