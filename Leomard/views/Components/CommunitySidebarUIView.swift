//
//  CommunitySidebarUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct CommunityUISidebarView: View {
    let communityResponse: GetCommunityResponse
    
    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .bottomLeading) {
                    if let banner = communityResponse.communityView.community.banner {
                        AsyncImage(url: URL(string: banner)!, content: { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity,
                                        minHeight: 0,
                                        maxHeight: .infinity,
                                        alignment: .top
                                    )
                                    .scaledToFit()
                            default:
                                EmptyView()
                            }
                        })
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                    }
                    CommunityAvatar(community: communityResponse.communityView.community, size: 120)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .bottomLeading
                        )
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .padding(.bottom, 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                VStack {
                    Text(communityResponse.communityView.community.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 24))
                    Text(communityResponse.communityView.community.name + "@" + LinkHelper.stripToHost(link: communityResponse.communityView.community.actorId))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                }
                .padding()
                .padding(.top, -20)
                Spacer()
                HStack(spacing: 25) {
                    HStack(spacing: 7) {
                        Image(systemName: "calendar.badge.plus")
                        DateDisplayView(date: communityResponse.communityView.counts.published, showRealTime: true, noBrackets: true, noTapAction: true, prettyFormat: true)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
                .padding(.top, -20)
                Spacer()
                HStack() {
                    Button(getSubscribeButtonText(), action: onSubscribeButtonClick)
                        .buttonStyle(.borderedProminent)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                            )
                }
                .padding()
                .padding(.top, 0)
                .padding(.bottom, 0)
                .frame(maxWidth: .infinity)
                if let description = communityResponse.communityView.community.description {
                    Markdown(MarkdownContent(description))
                        .lineLimit(nil)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                        .padding()
                    Spacer()
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .background(Color(.textBackgroundColor))
        }
    }
    
    func onSubscribeButtonClick() {
        
    }
    
    func getSubscribeButtonText() -> String {
        return communityResponse.communityView.subscribed == .notSubscribed ? "Subscribe" : "Unsubscribe"
    }
}
