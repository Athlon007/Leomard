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
    @State var crossPost: PostView? = nil
    
    @Binding var columnStatus: NavigationSplitViewVisibility
    @State var unreadMessages: Int = 0
    
    @State var addingNewUser: Bool = false
    
    @State var interactionEnabled: Bool = true
    
    @State var reportingPost: Bool = false
    @State var reportedPost: Post? = nil
    @State var reportingComment: Bool = false
    @State var reportedComment: Comment? = nil
    
    @State var reportReason: String = ""
    @State var reportSent: Bool = false
    @State var reportSuccess: Bool = false
    
    @State var showUnrecognizedLinkError: Bool = false
    
    @State var imageUploadFail: Bool = false
    @State var imageUploadFailReason: String = ""
    
    var appIconBadge = AppAlertBadge()
    
    var body: some View {
        // - TODO: We're using this ZStack so we can add modal popups over our navigation split view. Perhaps using the `.overlay()` modifier on the split view might be more appropriate?
        ZStack {
            if UserPreferences.getInstance.twoColumnView {
                twoColumnView
            } else {
                classicView
            }
            postCreationPopup(openedPostMakingForCommunity)
        }
        .allowsHitTesting(interactionEnabled)
        .overlay(Color.gray.opacity(interactionEnabled ? 0 : 0.5))
        .alert("Report Post", isPresented: $reportingPost, actions: {
            TextField("Reason", text: $reportReason)
            Spacer()
            Button("Report", role: .destructive) {
                self.postService!.report(post: reportedPost!, reason: reportReason) { result in
                    switch result {
                    case .success(_):
                        reportSuccess = true
                        reportSent = true
                    case .failure(let error):
                        print(error)
                        reportSuccess = false
                        reportSent = true
                    }
                }
            }
            .disabled(reportReason.count == 0)
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("State the reason of your report:")
        })
        .alert("Report Comment", isPresented: $reportingComment, actions: {
            TextField("Reason", text: $reportReason)
            Spacer()
            Button("Report", role: .destructive) {
                self.commentService!.report(comment: reportedComment!, reason: reportReason) { result in
                    switch result {
                    case .success(_):
                        reportSuccess = true
                        reportSent = true
                    case .failure(let error):
                        print(error)
                        reportSuccess = false
                        reportSent = true
                    }
                }
            }
            .disabled(reportReason.count == 0)
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("State the reason of your report:")
        })
        .alert(reportSuccess ? "Success!" : "Error",
               isPresented: $reportSent, actions: {},
               message: { Text(reportSuccess ? "Your report has been sent." : "Failed to send report. Try again later.") })
        .handlesExternalEvents(preferring: ["{path of URL?}"], allowing: ["*"])
        .onOpenURL { url in
            handleUrl(url)
        }
        .onAppear {
            // Observe the custom notification when the view appears
            NotificationCenter.default.addObserver(forName: NSNotification.Name("CustomURLReceived"), object: nil, queue: nil) { notification in
                if let url = notification.object as? URL {
                    handleUrl(url)
                }
            }
        }
        .alert("Unrecognized Link", isPresented: $showUnrecognizedLinkError, actions: {
            Button("OK", action: {})
        }, message: { Text("Link could not be recognized neither as community nor person link.")})
        .alert("Image Upload Failed", isPresented: $imageUploadFail, actions: {
            Button("OK") {}
        }, message: {
            Text(imageUploadFailReason)
        })
    }
    
    @ViewBuilder
    private var classicView: some View {
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
    }
    
    @ViewBuilder
    private var twoColumnView: some View {
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
        } content: {
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
        } detail: {
            if self.openedPostView != nil {
                List {
                    PostOpenedView(postView: self.openedPostView!, contentView: self, commentService: commentService!, postService: postService!, myself: $myUser)
                }
                .frame(minWidth: 400)
            }
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
                editedPost: editedPost,
                crossPost: crossPost)
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
    }
    
    func openPost(postView: PostView) {
        postHidden = false
        if self.openedPostView != nil {
            if UserPreferences.getInstance.twoColumnView && self.openedPostView == postView {
                self.openedPostView = nil
                return
            }
            
            self.openedPostView = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.openedPostView = postView
            }
        } else {
            self.openedPostView = postView
        }
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
        self.editedPost = nil
        self.crossPost = nil
    }
    
    func openPostEdition(post: PostView, onPostEdited: @escaping (PostView) -> Void) {
        self.editedPost = post
        openedPostMakingForCommunity = post.community
        self.onPostAdded = onPostEdited
    }
    
    func closePostEdit() {
        openedPostMakingForCommunity = nil
        self.editedPost = nil
        self.crossPost = nil
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
    
    func startReport(_ comment: Comment) {
        self.reportedComment = comment
        reportingComment = true
    }
    
    func handleUrl(_ url: URL) {
        let main: String = url.absoluteString.components(separatedBy: ":")[1].replacingOccurrences(of: "//", with: "")
        if main.starts(with: "@") {
            // Handle Person link.
            let searchService = SearchService(requestHandler: RequestHandler())
            searchService.search(query: main, searchType: .users, page: 1) { result in
                switch result {
                case .success(let response):
                    if response.users.count != 0 {
                        openPerson(profile: response.users[0].person)
                    }
                case .failure(let error):
                    print(error)
                    // TODO: Show error message.
                }
            }
        } else if (main.starts(with: "!")) {
            // Handle Community Link
            let searchService = SearchService(requestHandler: RequestHandler())
            searchService.search(query: main, searchType: .communities, page: 1) { result in
                switch result {
                case .success(let response):
                    if response.communities.count != 0 {
                        openCommunity(community: response.communities[0].community)
                    }
                case .failure(let error):
                    print(error)
                    // TODO: Show error message.
                }
            }
        } else {
            showUnrecognizedLinkError = true
        }
    }
    
    func openCrossPost(post: PostView) {
        self.crossPost = post
        openedPostMakingForCommunity = post.community
        self.onPostAdded = { post in
            self.openPost(postView: post)
        }
    }
    
    func addImage(completion: @escaping (Result<ImgurImageUploadResponse, Error>) -> Void) {
        let panel = NSOpenPanel()
        panel.prompt = "Select file"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .init(importedAs: "leomard.supported.image.types.jpg"),
            .init(importedAs: "leomard.supported.image.types.jpeg"),
            .init(importedAs: "leomard.supported.image.types.png"),
            .init(importedAs: "leomard.supported.image.types.webp"),
            .init(importedAs: "leomard.supported.image.types.gif")
        ]
        panel.begin { (result) -> Void in
            toggleInteraction(true)
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue, let url = panel.url {
                let imageService = ImageService(requestHandler: RequestHandler())
                imageService.uploadImage(url: url) { result in
                    switch result {
                    case .success(let imageUploadResponse):
                        completion(.success(imageUploadResponse))
                    case .failure(let error):
                        if error is LeomardExceptions {
                            self.imageUploadFailReason = String(describing: error as! LeomardExceptions)
                        } else {
                            self.imageUploadFailReason = "Unable to upload the image :("
                        }
                        self.imageUploadFail = true
                        
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.failure(LeomardExceptions.userCancelledOperation("User cancelled image upload.")))
            }
        }
        panel.orderFrontRegardless()
        toggleInteraction(false)
    }
}
