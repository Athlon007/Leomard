//
//  NavbarView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

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
        VStack {
            ForEach(options, id: \.self) { option in
                NavbarItem(option: option, currentSelection: $currentSelection, contentView: contentView, currentCommunity: $currentCommunity, badgeCount: option.id == 1 ? $unreadMessagesCount : $emptyCounter)
            }
        }
        .NavBarItemContainer()
        .padding(.top, 24)
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
        .frame(
            minHeight: 0,
            maxHeight: .infinity
        )
        VStack {
            NavbarItem(option: profileOption, currentSelection: $currentSelection, contentView: contentView, currentCommunity: $currentCommunity, badgeCount: $emptyCounter)
        }
        .NavBarItemContainer()
    }

}
