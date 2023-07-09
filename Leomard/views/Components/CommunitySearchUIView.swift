//
//  CommunityUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

struct CommunitySearchUIView: View {
    @State var communityView: CommunityView
    let contentView: ContentView
    
    var body: some View {
        ZStack {
            /*
            if communityView.community.banner != nil {
                AsyncImage(url: URL(string: communityView.community.banner!)!, content: { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.1)
                            .frame(maxWidth: 600, maxHeight: .infinity)
                    default:
                        VStack {}
                    }
                })
                .padding(.trailing, -25)
            }
             */
            HStack {
                CommunityAvatar(community: communityView.community, size: 100)
                VStack(spacing: 10) {
                    VStack {
                        Text(communityView.community.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 18))
                        Text(communityView.community.name + "@" + LinkHelper.stripToHost(link: communityView.community.actorId))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        HStack(spacing: 7) {
                            Image(systemName: "person.3")
                            Text(String(communityView.counts.subscribers))
                        }.help("Subscribers")
                        HStack(spacing: 7) {
                            Image(systemName: "eye")
                            Text(String(communityView.counts.usersActiveHalfYear))
                        }.help("Active Users (6 months)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: 600, maxHeight: 100, alignment: .leading)
        .onTapGesture {
            contentView.openCommunity(community: communityView.community)
        }
    }
}
