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
    @State var communityResponse: GetCommunityResponse
    let communityService: CommunityService
    let contentView: ContentView
    @Binding var myself: MyUserInfo?
    var onPostAdded: (PostView) -> Void
    
    @State var showConfirmCommunityBlock: Bool = false
    @State var showBlockFailure: Bool = false
    
    var body: some View {
        LazyVStack {
            ZStack() {
                if communityResponse.communityView.community.banner != nil {
                    AsyncImage(url: URL(string: communityResponse.communityView.community.banner!)!, content: { phase in
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
                                    alignment: .bottom
                                )
                        default:
                            EmptyView()
                        }
                    })
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 150,
                        maxHeight: 150
                    )
                }
                CommunityAvatar(community: communityResponse.communityView.community, size: 120)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.bottom, -60)
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
            .padding(.top, 45)
            Spacer()
            HStack(spacing: 25) {
                HStack(spacing: 7) {
                    Image(systemName: "calendar.badge.plus")
                    DateDisplayView(date: communityResponse.communityView.counts.published, showRealTime: true, noBrackets: true, noTapAction: true, prettyFormat: true)
                }.help("Created")
                HStack(spacing: 7) {
                    Image(systemName: "person.3")
                    Text(String(communityResponse.communityView.counts.subscribers))
                }.help("Subscribers")
                HStack(spacing: 7) {
                    Image(systemName: "eye")
                    Text(String(communityResponse.communityView.counts.usersActiveHalfYear))
                }.help("Active Users (6 months)")
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
                        alignment: .leading
                    )
                    .padding(.top, -20)
                    .padding(.bottom, -20)
                if myself != nil {
                    Button(action: openPostCreator) {
                        Image(systemName: "square.and.pencil")
                    }
                    .frame(
                        alignment: .leading
                    )
                    .padding(.top, -20)
                    .padding(.bottom, -20)
                    Button(action: {
                        if isCommunityBlocked() {
                            blockCommunity()
                        } else {
                            showConfirmCommunityBlock = true
                        }
                        
                    } ) {
                        Image(systemName: "person.fill.xmark")
                            .foregroundColor(isCommunityBlocked() ? .red : .primary)
                    }
                    .padding(.top, -20)
                    .padding(.bottom, -20)
                    .alert("Confirm", isPresented: $showConfirmCommunityBlock, actions: {
                        Button("Block", role: .destructive) { blockCommunity() }
                        Button("Cancel", role: .cancel) {}
                    }, message: { Text("Are you sure you want to block this community?") })
                }
                Spacer()
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
                    .padding(.top, -20)
                Spacer()
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .background(Color(.textBackgroundColor))
        .contextMenu {
            CommunityContextMenu(communityView: self.communityResponse.communityView)
        }
        .alert("Blocking Failed", isPresented: $showBlockFailure, actions: {
            Button("OK", role: .cancel) {}
        }, message: { Text("Failed to block the community. Try again later.")})
    }
    
    func onSubscribeButtonClick() {
        let subscribe = communityResponse.communityView.subscribed == .notSubscribed
        communityService.followCommunity(community: communityResponse.communityView.community, follow: subscribe) { result in
            switch result {
            case .success(let response):
                self.communityResponse.communityView = response.communityView
                self.contentView.reloadSubscriptionList()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getSubscribeButtonText() -> String {
        return communityResponse.communityView.subscribed == .notSubscribed ? "Subscribe" : "Unsubscribe"
    }
    
    func openPostCreator() {
        contentView.openPostCreation(community: communityResponse.communityView.community, onPostAdded: onPostAdded)
    }
    
    func isCommunityBlocked() -> Bool {
        if myself == nil {
            return false
        }
        
        for communityBlockView in myself!.communityBlocks {
            if communityBlockView.community.actorId == communityResponse.communityView.community.actorId {
                return true
            }
        }
        
        return false
    }
    
    func blockCommunity() {
        communityService.block(community: communityResponse.communityView.community, block: !isCommunityBlocked()) { result in
            switch result {
            case .success(let blockCommunityResponse):
                if blockCommunityResponse.blocked {
                    myself!.communityBlocks.append(CommunityBlockView(community: communityResponse.communityView.community, person: myself!.localUserView.person))
                } else {
                    myself!.communityBlocks = myself!.communityBlocks.filter { $0.community != communityResponse.communityView.community }
                }
            case .failure(let error):
                print(error)
                showBlockFailure = true
            }
        }
    }
}
