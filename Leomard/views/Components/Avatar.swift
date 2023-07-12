//
//  UserIconImage.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

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
        if person.avatar != nil {
            AsyncImage(url: URL(string: person.avatar!),
                       content: { phase in
                switch phase {
                case .success(let image):
                    image.AvatarFormatting(size: size)
                default:
                    Image(systemName: "person.circle")
                        .AvatarFormatting(size: size)
                        .foregroundColor(.black)
                }
            })
        } else {
            Image(systemName: "person.circle")
                .AvatarFormatting(size: size)
                .foregroundColor(.black)
        }
    }
}

struct CommunityAvatar: View {
    let community: Community
    var size: CGFloat = 20
    
    var body: some View {
        if community.icon != nil {
            AsyncImage(url: URL(string: community.icon!),
                       content: { phase in
                switch phase {
                case .success(let image):
                    image.AvatarFormatting(size: size)
                default:
                    Image(systemName: "person.2.circle")
                        .AvatarFormatting(size: size)
                        .foregroundColor(.black)
                }
            })
        } else {
            Image(systemName: "person.2.circle")
                .AvatarFormatting(size: size)
                .foregroundColor(.black)
        }
    }
}

struct SiteAvatar: View {
    let site: Site
    var size: CGFloat = 20
    
    var body: some View {
        if let icon = site.icon {
            AsyncImage(url: URL(string: icon),
                       content: { phase in
                switch phase {
                case .success(let image):
                    image.AvatarFormatting(size: size)
                default:
                    Image(systemName: "person.2.circle")
                        .AvatarFormatting(size: size)
                        .foregroundColor(.black)
                }
            })
        } else {
            Image(systemName: "person.2.circle")
                .AvatarFormatting(size: size)
                .foregroundColor(.black)
        }
    }
}
