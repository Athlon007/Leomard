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
    let profileOption: Option
    @Binding var currentSelection: Option
    @Binding var followedCommunities: [CommunityFollowerView]
    
    @Namespace var ns
    
    var body: some View {
        VStack {
            ForEach(options, id: \.self) { option in
                NavbarItem(option: option, currentSelection: $currentSelection)
            }
        }
        .NavBarItemContainer()
        .padding(.top, 24)
        List {
            Text("Followed")
            ForEach(followedCommunities, id: \.self) { communityView in
                NavbarCommunityItem(community: communityView.community)
            }
        }
        .frame(
            minHeight: 0,
            maxHeight: .infinity
        )
        VStack {
            NavbarItem(option: profileOption, currentSelection: $currentSelection)
        }
        .NavBarItemContainer()
    }

}
