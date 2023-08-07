//
//  NavbarItem.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct NavbarItem: View {
    let option: Option
    @Binding var currentSelection: Option
    let contentView: ContentView
    @Binding var currentCommunity: Community?
    @Binding var badgeCount: Int
    
    var body: some View {
        HStack {
            if let link = option.externalLink {
                LazyImage(url: .init(string: link), transaction: .init(animation: .easeOut)) { state in
                    if let image = state.image {
                        image.resizable()
                            .AvatarFormatting(size: 20)
                    } else if let _ = state.error {
                        Image(systemName: option.imageName)
                            .AvatarFormatting(size: 20)
                    } else {
                        Image(systemName: option.imageName)
                            .AvatarFormatting(size: 20)
                    }
                }
            } else {
                Image(systemName: option.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 20,
                        alignment: .leading
                    )
                    .foregroundColor(currentSelection == option && currentCommunity == nil ? Color(.linkColor) : Color(.labelColor))
            }
            Text(option.title)
                .frame(
                    //maxWidth: .infinity,
                    alignment: .leading
                )
                .foregroundColor(currentSelection == option && currentCommunity == nil ? Color(.linkColor) : Color(.labelColor))
            if badgeCount > 0 {
                VStack {
                    Text(String(badgeCount))
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
                .frame(width: 16, height: 16)
                .background(.red)
                .clipShape(Circle())
                .padding(.leading, 0)
            }
            Spacer()
        }
        .padding(.bottom, 10)
        .onTapGesture {
            self.currentSelection = option
            contentView.dismissProfileView()
            contentView.dismissCommunity()
        }
    }
}

struct NavbarCommunityItem: View {
    let community: Community
    @Binding var currentCommunity: Community?
    let contentView: ContentView
    
    var body: some View {
        HStack {
            LazyImage(url: .init(string: community.icon ?? ""), transaction: .init(animation: .easeOut)) { state in
                if let image = state.image {
                    image.AvatarFormatting(size: 20)
                } else {
                    Image(systemName: "person.2.circle")
                        .AvatarFormatting(size: 20)
                        .foregroundColor(.black)
                }
            }
            Text(
                UserPreferences.getInstance.showCommunitiesInstances ?
                    (UserPreferences.getInstance.preferDisplayNameCommunityFollowed ? community.title : community.name) + "@" + LinkHelper.stripToHost(link: community.actorId)
                :
                    (UserPreferences.getInstance.preferDisplayNameCommunityFollowed ? community.title : community.name)
            )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .foregroundColor(currentCommunity == community ? Color(.linkColor) : Color(.labelColor))
            Spacer()
        }
        .padding(.bottom, 10)
        .onTapGesture {
            self.contentView.openCommunityFromSidebar(community: community)
        }
        .background(Color.gray.opacity(0))
    }
}
