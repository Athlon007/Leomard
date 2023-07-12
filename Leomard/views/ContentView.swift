//
//  ContentView.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import SwiftUI
import MarkdownUI

struct ContentView: View {
    //@StateObject var userPreferences: UserPreferences
    
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
    @State var repliesService: RepliesService?
    
    @State var openedPostView: PostView? = nil
    @State var postHidden: Bool = false
    @State var openedPerson: Person? = nil
    @State var openedCommunity: Community? = nil
    @State var showDismissInCommunityView: Bool = true
    // Post creation
    @State var openedPostMakingForCommunity: Community? = nil
    @State var onPostAdded: ((PostView) -> Void)? = nil
    @State var editedPost: PostView? = nil
    
    @Binding var columnStatus: NavigationSplitViewVisibility
    @State var unreadMessages: Int = 0
    
    var body: some View {
        ZStack {
            NavigationSplitView(columnVisibility: $columnStatus) {
                NavbarView(
                    options: options,
                    profileOption: $profileOption,
                    currentSelection: $currentSelection,
                    followedCommunities: $followedCommunities,
                    contentView: self,
                    currentCommunity: $openedCommunity,
                    unreadMessagesCount: $unreadMessages
                )
                .listStyle(SidebarListStyle())
                .navigationBarBackButtonHidden(true)
                .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 750)
            } detail: {
                ZStack {
                    VStack {
                        switch currentSelection.id {
                        case 1:
                            InboxView(repliesService: self.repliesService!, requestHandler: self.requestHandler!, sessionService: self.sessionService, myself: $myUser, contentView: self, commentService: self.commentService!)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        case 2:
                            SearchView(sessionService: sessionService, postService: postService!, commentService: commentService!, contentView: self, myself: $myUser)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        case 3:
                            if self.sessionService.isSessionActive() && myUser != nil {
                                ProfileView(sessionService: sessionService, commentService: commentService!, contentView: self, person: myUser!.localUserView.person, myself: $myUser)
                                    .listStyle(SidebarListStyle())
                                    .scrollContentBackground(.hidden)
                            } else {
                                LoginView(sessionService: sessionService, requestHandler: requestHandler!, contentView: self)
                                    .frame(maxWidth: .infinity)
                                    .listStyle(SidebarListStyle())
                                    .scrollContentBackground(.hidden)
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
                            CommunityUIView(community: openedCommunity!, sessionService: self.sessionService, postService: self.postService!, commentService: self.commentService!, contentView: self, myself: myUser, showDismissInCommunityView: $showDismissInCommunityView)
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
                self.requestHandler = RequestHandler()
                self.siteService = SiteService(requestHandler: self.requestHandler!)
                self.commentService = CommentService(requestHandler: self.requestHandler!)
                self.postService = PostService(requestHandler: self.requestHandler!)
                self.repliesService = RepliesService(requestHandler: self.requestHandler!)
                
                self.loadUserData()
                self.updateUnreadMessagesCount()
                self.startPeriodicUnreadMessageCheck()
            }
            
            if self.openedPostView != nil {
                PostPopup(postView: openedPostView!, contentView: self, commentService: commentService!, postService: postService!, myself: $myUser)
                    .opacity(postHidden ? 0 : 1)
            }
            
            if self.openedPostMakingForCommunity != nil {
                PostCreationPopup(contentView: self, community: openedPostMakingForCommunity!, postService: postService!, myself: $myUser, onPostAdded: self.onPostAdded!, editedPost: editedPost)
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
        
        updateUnreadMessagesCount()
    }
    
    func openPost(postView: PostView) {
        postHidden = false
        self.openedPostView = nil
        self.openedPostView = postView
    }
    
    func openPostForComment(comment: Comment) {
        postService?.getPostForComment(comment: comment) { result in
            switch result {
            case .success(let postResponse):
                self.openedPostView = postResponse.postView
            case .failure(let error):
                print(error)
            }
        }
    }

    func closePost() {
        self.openedPostView = nil
    }
    
    func logout() {
        myUser = nil
        siteView = nil
        followedCommunities = []
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
        self.openedCommunity = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // A small hack to force SwiftUI to redraw the ComunityView
            self.openedCommunity = community
        }
        self.postHidden = true
    }
    
    func dismissCommunity() {
        self.openedCommunity = nil
        self.postHidden = false
        showDismissInCommunityView = true
    }
    
    func openCommunityFromSidebar(community: Community) {
        showDismissInCommunityView = false
        openCommunity(community: community)
    }
    
    func reloadSubscriptionList() {
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
    
    func openPostCreation(community: Community, onPostAdded: @escaping (PostView) -> Void) {
        openedPostMakingForCommunity = community
        self.onPostAdded = onPostAdded
    }
    
    func closePostCreation() {
        openedPostMakingForCommunity = nil
    }
    
    func openPostEdition(post: PostView, onPostEdited: @escaping (PostView) -> Void) {
        self.editedPost = post
        openedPostMakingForCommunity = post.community
        self.onPostAdded = onPostEdited
    }
    
    func closePostEdit() {
        openedPostMakingForCommunity = nil
        self.editedPost = nil
    }
    
    func updateUnreadMessagesCount() {
        self.repliesService!.getCounts { result in
            switch result {
            case .success(let unreadCountsResponse):
                self.unreadMessages = unreadCountsResponse.total()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startPeriodicUnreadMessageCheck() {
        // Check every 1 minute if we got a new unread message.
        if UserPreferences().checkNotifsEverySeconds <= -1 || myUser == nil {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(UserPreferences().checkNotifsEverySeconds)) { [self] in
            self.updateUnreadMessagesCount()
            self.startPeriodicUnreadMessageCheck()
        }
    }
}
