//
//  ProfileView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let sessionService: SessionService
    let contentView: ContentView
    @Binding var myself: MyUserInfo?
    
    @State var postService: PostService? = nil    
    let browseOptions: [Option] = [
        .init(id: 0, title: "Comments", imageName: "message"),
        .init(id: 1, title: "Posts", imageName: "doc.plaintext"),
        .init(id: 2, title: "Saved", imageName: "star")
    ]
    @State var selectedBrowseOption: Option = Option(id: 0, title: "Comments", imageName: "message")
    
    @State var postViews: [PostView] = []
    @State var commentViews: [CommentView] = []
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: selectedBrowseOption.imageName)
                    .padding(.trailing, 0)
                Picker("", selection: $selectedBrowseOption) {
                    ForEach(browseOptions, id: \.self) { method in
                        Text(method.title)
                    }
                }
                .frame(maxWidth: 120)
                .padding(.leading, -10)
                .onChange(of: selectedBrowseOption) { value in
                    self.reloadFeed()
                    self.loadPosts()
                }
            }
            Button(action: reloadFeed) {
                Image(systemName: "arrow.clockwise")
            }
            Button("Logout", action: logout)
        }
        .frame(
            minWidth: 0,
            idealWidth: .infinity
        )
        VStack {
            GeometryReader { proxy in
                HStack {
                    ScrollViewReader { scrollProxy in
                        List {
                            ForEach(postViews, id: \.self) { postView in
                                PostUIView(postView: postView, shortBody: true, postService: self.postService!, myself: $myself)
                                    .onAppear {
                                        if postView == self.postViews.last {
                                            self.loadPosts()
                                        }
                                    }
                                    .onTapGesture {
                                        self.contentView.openPost(postView: postView)
                                    }
                                    .contextMenu {
                                        PostContextMenu(postView: postView)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                Spacer()
                                    .frame(height: 0)
                                
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    }
                    
                    if proxy.size.width > 1000 {
                        List {
                            VStack {
                                if myself != nil {
                                    ProfileSidebarUIView(person: myself!.localUserView.person, aggregates: myself!.localUserView.counts)
                                }
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity
                            )
                            .cornerRadius(4)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: 400,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
        .cornerRadius(4)
        .task {
            self.postService = PostService(requestHandler: RequestHandler(sessionService: self.sessionService), sessionService: sessionService)
            loadPosts()
        }
        Spacer()
    }
    
    func logout() {
        sessionService.destroy()
        contentView.navigateToFeed()
        contentView.logout()
    }
    
    func loadPosts() {
        
    }
    
    func reloadFeed() {
        
    }
}
