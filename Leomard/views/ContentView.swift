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
    @State var profileOption: Option = Option(id: 3, title: "Profile", imageName: "person.crop.circle")
    @State var followedCommunities: [CommunityFollowerView] = []
    @State var myUser: MyUserInfo? = nil
    @State var siteView: SiteView? = nil
    
    let sessionService = SessionService()
    @State var requestHandler: RequestHandler?
    @State var siteService: SiteService?
    @State var commentService: CommentService?
    @State var postService: PostService?
    
    @State var openedPostView: PostView? = nil
    @State var postHidden: Bool = false
    @State var openedPerson: Person? = nil
    @State var openedCommunity: Community? = nil

    
    var body: some View {
        ZStack {
            NavigationSplitView {
                NavbarView(
                    options: options,
                    profileOption: $profileOption,
                    currentSelection: $currentSelection,
                    followedCommunities: $followedCommunities,
                    contentView: self
                )
                .listStyle(SidebarListStyle())
                .navigationBarBackButtonHidden(true)
                .frame(
                    minWidth: 50
                )
            } detail: {
                ZStack {
                    VStack {
                        switch currentSelection.id {
                        case 3:
                            if self.sessionService.isSessionActive() {
                                ProfileView(sessionService: sessionService, commentService: commentService!, contentView: self, person: myUser!.localUserView.person, myself: $myUser)
                                    .listStyle(SidebarListStyle())
                                    .scrollContentBackground(.hidden)
                            } else {
                                LoginView(sessionService: sessionService, requestHandler: requestHandler!, contentView: self)
                            }
                        default:
                            FeedView(sessionService: sessionService, contentView: self, myself: $myUser, siteView: $siteView)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        }
                    }
                    
                    if openedPerson != nil {
                        VStack {
                            ProfileView(sessionService: sessionService, commentService: commentService!, contentView: self, person: openedPerson!, myself: $myUser)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        }
                        .listStyle(SidebarListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.thickMaterial)
                    }
                    
                    if openedCommunity != nil {
                        VStack {
                            CommunityUIView(communityId: openedCommunity!.id, sessionService: self.sessionService, postService: self.postService!, commentService: self.commentService!, contentView: self)
                        }
                        .listStyle(SidebarListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.thickMaterial)
                    }
                }
                .frame(minWidth: 600, minHeight: 400)
            }
            .frame(minWidth: 600, minHeight: 400)
            .task {
                self.currentSelection = self.options[0]
                self.requestHandler = RequestHandler(sessionService: self.sessionService)
                self.siteService = SiteService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                self.commentService = CommentService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                self.postService = PostService(requestHandler: self.requestHandler!, sessionService: self.sessionService)
                
                self.loadUserData()
            }

            if self.openedPostView != nil {
                PostPopup(postView: openedPostView!, contentView: self, commentService: commentService!, postService: postService!, myself: $myUser)
                    .opacity(postHidden ? 0 : 1)
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
                    self.profileOption.title = self.myUser!.localUserView.person.name
                    if self.myUser!.localUserView.person.avatar != nil {
                        self.profileOption.externalLink = self.myUser!.localUserView.person.avatar!
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func openPost(postView: PostView) {
        postHidden = false
        self.openedPostView = nil
        self.openedPostView = postView
    }
    
    func closePost() {
        self.openedPostView = nil
    }
    
    func logout() {
        myUser = nil
        siteView = nil
        followedCommunities.removeAll()
        self.profileOption.title = "Profile"
        self.profileOption.externalLink = nil
        postHidden = false
        openedPostView = nil
        openedPerson = nil
        
        loadUserData()
    }
    
    func openPerson(profile: Person) {
        dismissCommunity()
        self.openedPerson = profile
        self.postHidden = true
    }
    
    func dismissProfileView() {
        self.openedPerson = nil
        postHidden = false
    }
    
    func hidePost() {
        postHidden = true
    }
    
    func openCommunity(community: Community) {
        dismissProfileView()
        self.openedCommunity = community
        self.postHidden = true
    }
    
    func dismissCommunity() {
        self.openedCommunity = nil
        self.postHidden = false
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
