//
//  UserIconImage.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI
import NukeUI

extension Image {
    func AvatarFormatting(size: CGFloat) -> some View {
        return self.resizable()
            .resizable()
            .antialiased(true)
            .interpolation(.high)
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size, alignment: .center)
            .background(.white)
            .clipShape(Circle())
    }
}

struct PersonAvatar: View {
    let person: Person
    var size: CGFloat = 20
    
    var body: some View {
        LazyImage(
            url: .init(string: person.avatar ?? ""),
            transaction: .init(animation: .easeOut)
        ) { state in
            if let image = state.image {
                image.AvatarFormatting(size: size)
            } else {
                Image(systemName: "person.circle")
                    .AvatarFormatting(size: size)
                    .foregroundColor(.black)
            }
        }
    }
}

struct CommunityAvatar: View {
    let community: Community
    var size: CGFloat = 20
    
    var body: some View {
        LazyImage(
            url: .init(string: community.icon ?? ""),
            transaction: .init(animation: .easeOut)
        ) { state in
            if let image = state.image {
                image.AvatarFormatting(size: size)
            } else {
                Image(systemName: "person.circle")
                    .AvatarFormatting(size: size)
                    .foregroundColor(.black)
            }
        }
    }
}

struct SiteAvatar: View {
    let site: Site
    var size: CGFloat = 20
    
    var body: some View {
        LazyImage(
            url: .init(string: site.icon ?? ""),
            transaction: .init(animation: .easeOut)
        ) { state in
            if let image = state.image {
                image.AvatarFormatting(size: size)
            } else {
                Image(systemName: "person.circle")
                    .AvatarFormatting(size: size)
                    .foregroundColor(.black)
            }
        }
    }
}
