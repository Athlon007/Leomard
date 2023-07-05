//
//  NavbarItem.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct NavbarItem: View {
    let option: Option
    @Binding var currentSelection: Option
    
    var body: some View {
        HStack {
            if let link = option.externalLink {
                AsyncImage(url: URL(string: link),
                           content: { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .AvatarFormatting(size: 20)
                    default:
                        Image(systemName: option.imageName)
                            .AvatarFormatting(size: 20)
                    }
                })
            } else {
                Image(systemName: option.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 20,
                        alignment: .leading
                    )
                    .foregroundColor(currentSelection == option ? Color(.linkColor) : Color(.labelColor))
            }
            Text(option.title)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .foregroundColor(currentSelection == option ? Color(.linkColor) : Color(.labelColor))
            Spacer()
        }
        .padding(.bottom, 10)
        .onTapGesture {
            self.currentSelection = option
        }
    }
}

struct NavbarCommunityItem: View {
    let community: Community
    
    var body: some View {
        HStack {
            if community.icon == nil {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 20,
                        alignment: .leading
                    )
            } else {
                AsyncImage(url: URL(string: community.icon!),
                           content: { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, alignment: .leading)
                        .clipShape(Circle())
                    default:
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: 20,
                                alignment: .leading
                            )
                    }
                })
            }
            Text(community.name + "@" + LinkHelper.stripToHost(link: community.actorId))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            Spacer()
        }
        .padding(.bottom, 10)
        .onTapGesture {
            // TODO: Load community.
        }
        .background(Color.gray.opacity(0))
    }
}
