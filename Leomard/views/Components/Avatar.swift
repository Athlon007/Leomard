//
//  UserIconImage.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

extension Image {
    func AvatarFormatting() -> some View {
        return self.resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .scaledToFit()
            .frame(width: 20, height: 20, alignment: .leading)
            .clipShape(Circle())
    }
}

struct PersonAvatar: View {
    let person: Person
    
    var body: some View {
        if person.avatar != nil {
            AsyncImage(url: URL(string: person.avatar!),
                       content: { phase in
                switch phase {
                case .success(let image):
                    image.AvatarFormatting()
                default:
                    Image(systemName: "person.circle")
                        .AvatarFormatting()
                }
            })
        } else {
            Image(systemName: "person.circle")
                .AvatarFormatting()
        }
    }
}

struct CommunityAvatar: View {
    let community: Community
    
    var body: some View {
        if community.icon != nil {
            AsyncImage(url: URL(string: community.icon!),
                       content: { phase in
                switch phase {
                case .success(let image):
                    image.AvatarFormatting()
                default:
                    Image(systemName: "person.2.circle")
                        .AvatarFormatting()
                }
            })
        } else {
            Image(systemName: "person.2.circle")
                .AvatarFormatting()
        }
    }
}

