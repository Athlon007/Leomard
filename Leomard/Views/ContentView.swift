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
    
    @State var addingNewUser: Bool = false
    
    @State var interactionEnabled: Bool = true
    
    @State var reportingPost: Bool = false
    @State var reportedPost: Post? = nil
    @State var reportReason: String = ""
    
    var appIconBadge = AppAlertBadge()
    
    var body: some View {
        // - TODO: We're using this ZStack so we can add modal popups over our navigation split view. Perhaps using the `.overlay()` modifier on the split view might be more appropriate?
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
                            InboxView(repliesService: self.repliesService!, requestHandler: self.requestHandler!, myself: $myUser, contentView: self, commentService: self.commentService!)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        case 2:
                            SearchView(postService: postService!, commentService: commentService!, contentView: self, myself: $myUser)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        case 3:
                            profileOrLoginView()
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        default:
                            FeedView(contentView: self, myself: $myUser, siteView: $siteView)
                                .listStyle(SidebarListStyle())
                                .scrollContentBackground(.hidden)
                        }
                    }
                    
                    profileView(openedPerson)
                        .listStyle(SidebarListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.thickMaterial)
                    communityView(openedCommunity)
                        .listStyle(SidebarListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.thickMaterial)
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
            }
            
            postPopup(openedPostView)
                .opacity(postHidden ? 0 : 1)
            postCreationPopup(openedPostMakingForCommunity)
        }
        .allowsHitTesting(interactionEnabled)
        .overlay(Color.gray.opacity(interactionEnabled ? 0 : 0.5))
        .alert("Report", isPresented: $reportingPost, actions: {
            TextField("Reason", text: $reportReason)
            Spacer()
            Button("Report", role: .destructive) {
                let postService = PostService(requestHandler: RequestHandler())
                postService.report(post: reportedPost!, reason: reportReason) { result in
                }
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("State the reason of your report:")
        })
    }
    
    /// - Returns: A view reflecting whether user is logged in to a profile or user needs to be prompted to log in.
    @ViewBuilder
    private func profileOrLoginView() -> some View {
        if SessionStorage.getInstance.isSessionActive() && myUser != nil && !addingNewUser {
            ProfileView(
                commentService: commentService!,
                contentView: self,
                person: myUser!.localUserView.person,
                myself: $myUser)
        } else {
            LoginView(requestHandler: requestHandler!, contentView: self)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func profileView(_ openedPerson: Person?) -> some View {
        if let openedPerson {
            VStack {
                ProfileView(commentService: commentService!, contentView: self, person: openedPerson, myself: $myUser)
                    .listStyle(SidebarListStyle())
                    .scrollContentBackground(.hidden)
            }
        }
    }
    
    @ViewBuilder
    private func communityView(_ openedCommunity: Community?) -> some View {
        if let openedCommunity {
            VStack {
                CommunityUIView(
                    community: openedCommunity,
                    postService: self.postService!,
                    commentService: self.commentService!,
                    contentView: self,
                    myself: myUser,
                    showDismissInCommunityView: $showDismissInCommunityView)
            }
        }
    }
    
    @ViewBuilder
    private func postPopup(_ openedPostView: PostView?) -> some View {
        if let openedPostView {
            PostPopup(
                postView: openedPostView,
                contentView: self,
                commentService: commentService!,
                postService: postService!,
                myself: $myUser)
        }
    }
    
    @ViewBuilder
    private func postCreationPopup(_ openedPostMakingForCommunity: Community?) -> some View {
        if let openedPostMakingForCommunity {
            PostCreationPopup(
                contentView: self,
                community: openedPostMakingForCommunity,
                postService: postService!,
                myself: $myUser,
                onPostAdded: self.onPostAdded!,
                editedPost: editedPost)
        }
    }
    
    // MARK: -
    
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
                    } else {
                        self.profileOption.externalLink = nil
                    }
                    
                    self.updateUnreadMessagesCount()
                    self.startPeriodicUnreadMessageCheck()
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
                DispatchQueue.main.sync {
                    if self.unreadMessages == 0 {
                        self.appIconBadge.resetBadge()
                    } else {
                        if self.unreadMessages > 99 {
                            self.appIconBadge.setBadge(text: "🙀")
                        } else {
                            self.appIconBadge.setBadge(number: self.unreadMessages)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startPeriodicUnreadMessageCheck() {
        // Check every 1 minute if we got a new unread message.
        if UserPreferences.getInstance.checkNotifsEverySeconds <= -1 || myUser == nil {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(UserPreferences.getInstance.checkNotifsEverySeconds)) { [self] in
            self.updateUnreadMessagesCount()
            self.startPeriodicUnreadMessageCheck()
        }
    }
    
    func addNewUserLogin() {
        addingNewUser = true
    }
    
    func endNewUserLogin() {
        addingNewUser = false
    }
    
    func toggleInteraction(_ enabled: Bool) {
        interactionEnabled = enabled
    }
    
    func startReport(_ post: Post) {
        self.reportedPost = post
        reportingPost = true
    }
}
