//
//  ContentView.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import SwiftUI
import MarkdownUI

struct ContentView: View {
    @State var currentSelection: Option = Option(id: 0, title: "Home", imageName: "house")
    var options: [Option] = [
        .init(id: 0, title: "Feed", imageName: "house"),
        .init(id: 1, title: "Inbox", imageName: "tray"),
        .init(id: 2, title: "Search", imageName: "magnifyingglass")
    ]
    var profileOption: Option = Option(id: 3, title: "Profile", imageName: "person.crop.circle")
    @State var followedCommunities: [CommunityFollowerView] = []
    @State var myUser: MyUserInfo? = nil
    @State var siteView: SiteView? = nil
    
    let sessionService = SessionService()
    @State var requestHandler: RequestHandler?
    @State var siteService: SiteService?
    @State var commentService: CommentService?
    @State var postService: PostService?
    
    @State var openedPostView: PostView? = nil
    @State var showingPopover = true

    
    var body: some View {
        ZStack {
            NavigationSplitView {
                NavbarView(
                    options: options,
                    profileOption: profileOption,
                    currentSelection: $currentSelection,
                    followedCommunities: $followedCommunities
                )
                .listStyle(SidebarListStyle())
                .navigationBarBackButtonHidden(true)
                .frame(
                    minWidth: 50
                    
                )

            } detail: {
                switch currentSelection.id {
                case 3:
                    if self.sessionService.isSessionActive() {
                        ProfileView(sessionService: sessionService, contentView: self)
                    } else {
                        LoginView(sessionService: sessionService, requestHandler: requestHandler!, contentView: self)
                    }
                default:
                    FeedView(sessionService: sessionService, contentView: self, siteView: $siteView)
                        .listStyle(SidebarListStyle())
                        .scrollContentBackground(.hidden)
                }
            }
            .frame(minWidth: 600, minHeight: 400)
            .background(.regularMaterial)
            .task {
                self.currentSelection = self.options[0]
                self.requestHandler = RequestHandler(sessionService: self.sessionService)
                self.siteService = SiteService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                self.commentService = CommentService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                self.postService = PostService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                
                self.loadUserData()
            }
            if self.openedPostView != nil {
                PostPopup(postView: openedPostView!, contentView: self, commentService: commentService!, postService: postService!)
            }
        }
    }
    
    func navigateToFeed() {
        self.currentSelection = self.options[0]
    }
    
    func loadUserData() {
        self.siteService!.getSite { result in
            switch (result) {
            case .success(let getSiteResponse):
                self.myUser = getSiteResponse.myUser
                self.siteView = getSiteResponse.siteView
                if self.myUser != nil {
                    self.followedCommunities = getSiteResponse.myUser!.follows
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func openPost(postView: PostView) {
        self.openedPostView = postView
    }
    
    func closePost() {
        self.openedPostView = nil
    }
    
    func logout() {
        myUser = nil
        siteView = nil
        followedCommunities.removeAll()
        
        loadUserData()
    }
}

enum FocusField: Hashable {
    case field
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
