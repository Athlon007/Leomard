//
//  ProfileView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let commentService: CommentService
    let contentView: ContentView
    @State var person: Person
    @Binding var myself: MyUserInfo?
    
    @State var personDetails: GetPersonDetailsResponse? = nil
    
    @State var postService: PostService? = nil
    @State var personService: PersonService? = nil
    @State var searchService: SearchService? = nil
    @State var browseOptions: [Option] = [
        .init(id: 0, title: "Comments", imageName: "message"),
        .init(id: 1, title: "Posts", imageName: "doc.plaintext"),
    ]
    @State var selectedBrowseOption: Option = Option(id: 0, title: "Comments", imageName: "message")
    @State var selectedSort: SortType = UserPreferences.getInstance.profileSortMethod
    
    @State var page: Int = 1
    
    @State fileprivate var selectededSession: SessionPickerOption = SessionPickerOption(title: "", sessionInfo: nil)
    @State fileprivate var sessions: [SessionPickerOption] = []
    @State fileprivate var addNewOption: SessionPickerOption = SessionPickerOption(title: "Add New", sessionInfo: nil)
    
    @State var sessionChangeFail: Bool = false
    
    @State var showLogoutAlert: Bool = false
    
    // Profile Editor Stuff
    let profileEditorTabs: [Option] = [
        .init(id: 0, title: "Settings", imageName: "gearshape"),
        .init(id: 1, title: "Person Blocks", imageName: "person.slash"),
        .init(id: 2, title: "Community Blocks", imageName: "person.2.slash")
    ]
    @State var selectedProfileEditorTab: Option = .init(id: 0, title: "Settings", imageName: "gearshape")
    @State var isEditingProfile: Bool = false
    @State var bio: String = ""
    @State var displayName: String = ""
    @State var updateProfileFail: Bool = false
    
    @State var searchVisible: Bool = false
    @State var searchQuery: String = ""
    @State var lastQuery: String = ""
    @State var showSearchPosts: Bool = false
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        toolbar
            .frame(
                minWidth: 0,
                maxWidth: .infinity
            )
            .padding(.leading)
            .padding(.trailing)
        profileContent
            .cornerRadius(8)
            .task {
                if person == myself?.localUserView.person {
                    browseOptions.append(Option(id: 2, title: "Saved", imageName: "star"))
                    if UserPreferences.getInstance.saveLikedPosts {
                        browseOptions.append(Option(id: 3, title: "Liked", imageName: "hand.thumbsup"))
                    }
                }
                
                let requestHandler = RequestHandler()
                self.postService = PostService(requestHandler: requestHandler)
                self.personService = PersonService(requestHandler: requestHandler)
                loadPersonDetails()
            }
        Spacer()
    }
    
    // MARK: -
    
    @ViewBuilder
    private var profileContent: some View {
        VStack {
            GeometryReader { proxy in
                HStack {
                    profileContentList(
                        personDetails,
                        sidebarVisible: proxy.size.width < 1000)
                    .frame(
                        minWidth: 0,
                        maxWidth: 600,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                    
                    profileSidebar(visible: proxy.size.width > 1000)
                        .frame(
                            minWidth: 0,
                            maxWidth: 400,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .overlay(profileEditor)
            }
            .alert("Error changing profile", isPresented: $sessionChangeFail, actions: {
                Button("OK", role: .cancel) {}
            }, message: { Text("Failed to change the session") })
        }
    }
    
    @ViewBuilder
    private func profileContentList(_ personDetails: GetPersonDetailsResponse?, sidebarVisible: Bool) -> some View {
        List {
            if let personDetails {
                /// Why are we showing another profile sidebar here?
                if sidebarVisible {
                    VStack {
                        ProfileSidebarUIView(personView: personDetails.personView, myself: $myself, personService: personService!, sender: self)
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity
                    )
                    .cornerRadius(8)
                    .padding(.bottom, 15)
                }
                switch selectedBrowseOption.id {
                case 0:
                    commentsList(personDetails)
                default:
                    postsList(personDetails)
                }
            }
        }
    }
    
    @ViewBuilder
    private func commentsList(_ personDetails: GetPersonDetailsResponse) -> some View {
        if personDetails.comments == [] {
            Text("No comments found!")
                .italic()
                .foregroundColor(.secondary)
        } else {
            ForEach(personDetails.comments, id: \.self) { commentView in
                VStack {
                    CommentUIView(commentView: commentView, indentLevel: 1, commentService: commentService, myself: $myself, post: commentView.post, contentView: contentView, profileViewMode: true)
                        .onAppear {
                            if commentView == personDetails.comments.last {
                                self.loadPersonDetails()
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                        .padding(.trailing, 15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .onTapGesture {
                    self.loadPostFromComment(commentView: commentView)
                }
                Spacer()
                    .frame(height: 0)
            }
        }
    }
    
    @ViewBuilder
    private func postsList(_ personDetails: GetPersonDetailsResponse) -> some View {
        if personDetails.posts == [] {
            Text("No posts found!")
                .italic()
                .foregroundColor(.secondary)
        } else {
            ForEach(personDetails.posts, id: \.self) { postView in
                PostUIView(postView: postView, shortBody: true, postService: self.postService!, myself: $myself, contentView: contentView)
                    .onAppear {
                        if postView == personDetails.posts.last {
                            self.loadPersonDetails()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                    .frame(height: 0)
            }
        }
    }
    
    @ViewBuilder
    private func profileSidebar(visible: Bool) -> some View {
        if visible {
            List {
                VStack {
                    if personDetails != nil {
                        ProfileSidebarUIView(personView: personDetails!.personView, myself: $myself, personService: personService!, sender: self)
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity
                )
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ViewBuilder
    private var toolbar: some View {
        HStack(spacing: 10) {
            dismissButton
            Spacer()
            profileToolbarItems
            Spacer()
            searchBox
            sessionPicker
        }
    }
    
    @ViewBuilder
    private var searchBox: some View {
        HStack {
            if searchVisible {
                TextField("Search", text: $searchQuery)
                    .frame(maxWidth: 200)
                    .onSubmit {
                        page = 1
                        search()
                    }
                    .cornerRadius(8)
            }
            Button(action: {
                searchVisible = !searchVisible
                if !searchVisible {
                    page = 1
                    loadPersonDetails()
                }
            }) {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.link)
        }
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        if person != myself?.localUserView.person {
            Button("Dismiss", action: contentView.dismissProfileView)
                .buttonStyle(.link)
        }
    }
    
    @ViewBuilder
    private var profileToolbarItems: some View {
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
                }
                Image(systemName: selectedSort.image)
                    .padding(.trailing, 0)
                Picker("", selection: $selectedSort) {
                    ForEach(UserPreferences.getInstance.profileSortTypes, id: \.self) { method in
                        Text(String(describing: method).spaceBeforeCapital())
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: selectedSort) { value in
                    self.reloadFeed()
                }
                .disabled(searchVisible)
            }
            Button(action: reloadFeed) {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
    
    /// Select a user/instance, or logout.
    @ViewBuilder
    private var sessionPicker: some View {
        HStack {
            if person == myself?.localUserView.person {
                Picker("", selection: $selectededSession) {
                    ForEach(sessions, id: \.self) { session in
                        if sessions.last == session {
                            Divider()
                        }
                        Text(session.title)
                    }
                }
                .frame(maxWidth: 120)
                .onChange(of: selectededSession) { change in
                    performSwitch(change)
                }
                Button("Logout", action: { showLogoutAlert = true })
                    .alert("Logout", isPresented: $showLogoutAlert, actions: {
                        Button("Logout", role: .destructive) { logout() }
                        Button("Cancel", role: .cancel) {}
                    }, message: {
                        Text("Are you sure you want to logout?")
                    })
            }
        }
    }
    
    @ViewBuilder
    private var profileEditor: some View {
        if isEditingProfile {
            ZStack {
                Color(white: 0, opacity: 0.33)
                    .onTapGesture {
                        isEditingProfile = false
                    }
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button("Dismiss", action: {isEditingProfile = false})
                                .buttonStyle(.link)
                            Spacer()
                            Button("Change More Settings", action: {
                                let instance = LinkHelper.stripToHost(link: myself!.localUserView.person.actorId)
                                self.openURL(URL(string: "https://" + instance + "/settings")!)
                            })
                            .buttonStyle(.link)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: selectedProfileEditorTab.imageName)
                                .padding(.trailing, 0)
                            Picker("", selection: $selectedProfileEditorTab) {
                                ForEach(profileEditorTabs, id: \.self) { method in
                                    Text(method.title)
                                }
                            }
                            .frame(maxWidth: 180)
                            Spacer()
                        }
                        switch selectedProfileEditorTab {
                        case profileEditorTabs[0]:
                            personEditor
                        case profileEditorTabs[1]:
                            personBlocks
                        case profileEditorTabs[2]:
                            communityBlocks
                        default:
                            HStack {
                                Spacer()
                                ProgressView().progressViewStyle(.circular)
                                Spacer()
                            }
                            Spacer()
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .frame(maxWidth: 600, maxHeight: 600)
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
                .cornerRadius(8)
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
            }
            .alert("Profile Update Failure", isPresented: $updateProfileFail, actions: {
                Button("OK") {}
            }, message: {
                Text("Failed to update the profile. Try again later.")
            })
            .task {
                selectedProfileEditorTab = profileEditorTabs[0]
            }
        }
    }
    
    @ViewBuilder
    private var personEditor: some View {
        List {
            VStack(alignment: .leading) {
                Text("Display Name")
                    .bold()
                TextField("Optional", text: $displayName)
            }
            VStack(alignment: .leading) {
                Text("Bio")
                    .bold()
                MarkdownEditor(bodyText: $bio, contentView: self.contentView)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            Spacer()
            VStack(alignment: .leading) {
                Button("Save Changes", action: {
                    userSettingsSave()
                })
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxHeight: .infinity)
        .textFieldStyle(.roundedBorder)
        .task {
            self.displayName = myself?.localUserView.person.displayName ?? ""
            self.bio = myself?.localUserView.person.bio ?? ""
        }
    }
    
    @ViewBuilder
    private var personBlocks: some View {
        List(myself!.personBlocks, id: \.self) { blockedPerson in
            HStack {
                Text( "@" + blockedPerson.target.name + "@" + LinkHelper.stripToHost(link: blockedPerson.target.actorId))
                Spacer()
                Button("Unblock", action: {
                    self.personService?.block(person: blockedPerson.target, block: false) { result in
                        switch result {
                        case .success(_):
                            myself!.personBlocks = myself!.personBlocks.filter { $0 != blockedPerson }
                        case .failure(let error):
                            print(error)
                        }
                    }
                })
            }
            if blockedPerson != myself!.personBlocks.last {
                Divider()
            }
        }
        .frame(maxHeight: .infinity)
        .textFieldStyle(.roundedBorder)
    }
    
    @ViewBuilder
    private var communityBlocks: some View {
        List(myself!.communityBlocks, id: \.self) { blockedCommunity in
            HStack {
                Text("!" + blockedCommunity.community.name + "@" + LinkHelper.stripToHost(link: blockedCommunity.community.actorId))
                Spacer()
                Button("Unblock", action: {
                    let communityService = CommunityService(requestHandler: RequestHandler())
                    communityService.block(community: blockedCommunity.community, block: false) { result in
                        switch result {
                        case .success(_):
                            myself!.communityBlocks = myself!.communityBlocks.filter { $0 != blockedCommunity }
                        case .failure(let error):
                            print(error)
                        }
                    }
                })
            }
            if blockedCommunity != myself!.communityBlocks.last {
                Divider()
            }
        }
        .frame(maxHeight: .infinity)
        .textFieldStyle(.roundedBorder)
        .task {
            myself = self.contentView.myUser
        }
    }

    
    // MARK: -
    
    func logout() {
        let toDestroy = SessionStorage.getInstance.getCurrentSession()
        if SessionStorage.getInstance.getAllSessions().count > 1 {
            // Is there more than 1 session stored? Switch to the one that's not used
            if SessionStorage.getInstance.getAllSessions()[0] == toDestroy {
                _ = SessionStorage.getInstance.setCurrentSession(SessionStorage.getInstance.getAllSessions()[1])
            } else {
                _ = SessionStorage.getInstance.setCurrentSession(SessionStorage.getInstance.getAllSessions()[0])
            }
            
            // Destroy the session
            _ = SessionStorage.getInstance.remove(session: toDestroy!)
            
            self.contentView.navigateToFeed()
            self.contentView.loadUserData()
        } else {
            _ = SessionStorage.getInstance.endSession()
            _ = SessionStorage.getInstance.remove(session: toDestroy!)
            contentView.navigateToFeed()
            contentView.logout()
        }
    }
    
    func loadPersonDetails() {
        if searchVisible {
            self.search()
            return
        }
        
        if page == 1 && self.personDetails != nil {
            self.personDetails!.comments = []
            self.personDetails!.posts = []
        }
        
        self.personService?.getPersonDetails(person: person, page: page, savedOnly: selectedBrowseOption.id == 2, sortType: selectedSort) { result in
            switch result {
            case .success(let personDetails):
                DispatchQueue.main.sync {
                    if self.personDetails != nil {
                        self.personDetails!.posts += personDetails.posts.filter { !self.personDetails!.posts.contains($0) }
                        self.personDetails!.comments += personDetails.comments.filter { !self.personDetails!.comments.contains($0) }
                    } else {
                        self.personDetails = personDetails
                    }
                    if self.personDetails?.personView.person == myself?.localUserView.person {
                        loadSessions()
                    }
                }
                
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func reloadFeed() {
        page = 1
        if selectedBrowseOption.id == 3 {
            loadLikedPosts()
        } else {
            loadPersonDetails()
        }
    }
    
    func loadPostFromComment(commentView: CommentView) {
        self.postService?.getPostForComment(comment: commentView.comment) { result in
            switch result {
            case .success(let getPostResponse):
                self.contentView.openPost(postView: getPostResponse.postView)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadSessions() {
        if self.sessions.count == 0 {
            for session in SessionStorage.getInstance.getAllSessions() {
                let sessionPickerOption = SessionPickerOption(title: "\(session.name)@\(session.lemmyInstance)", sessionInfo: session)
                self.sessions.append(sessionPickerOption)
                
                if SessionStorage.getInstance.getCurrentSession() == session {
                    self.selectededSession = sessionPickerOption
                }
            }
            self.sessions.append(SessionPickerOption(title: "Add New", sessionInfo: nil))
        }
    }
    
    fileprivate func performSwitch(_ selection: SessionPickerOption) {
        if let sessionInfo = selection.sessionInfo {
            let sessionNameAndInstance = (sessionInfo.name + "@" + sessionInfo.lemmyInstance).lowercased()
            if let myself = self.myself {
                let myselfSessionAndInstance = (myself.localUserView.person.name + "@" + LinkHelper.stripToHost(link: myself.localUserView.person.actorId)).lowercased()
                // Do not do anything, if selected is the same as current logged in user.
                if myselfSessionAndInstance == sessionNameAndInstance {
                    return
                }
                
                let sessionChanged = SessionStorage.getInstance.setCurrentSession(sessionInfo)
                if !sessionChanged {
                    sessionChangeFail = true
                    return
                }
                
                self.contentView.navigateToFeed()
                self.contentView.loadUserData()
            }
        } else {
            // Add user.
            self.contentView.addNewUserLogin()
        }
    }
    
    func editProfile() {
        isEditingProfile = true
    }
    
    func userSettingsSave() {
        self.personService?.saveUserSettings(oldSettings: myself!.localUserView, bio: bio, displayName: displayName) { result in
            switch result {
            case .success(let loginResponse):
                isEditingProfile = false
                let success = SessionStorage.getInstance.updateCurrent(loginResponse: loginResponse)
                if !success {
                    updateProfileFail = true
                    return
                }
                self.personDetails = nil
                self.contentView.myUser = nil
                self.contentView.loadUserData()
                self.myself = self.contentView.myUser
                loadPersonDetails()
            case .failure(let error):
                if let errorResponse = error as? ErrorResponse {
                    if errorResponse.error == "user_already_exists" {
                        self.personDetails = nil
                        self.contentView.myUser = nil
                        self.contentView.loadUserData()
                        self.myself = self.contentView.myUser
                        loadPersonDetails()
                        return
                    }
                }
                print(error)
                updateProfileFail = true
            }
        }
    }
    
    func search() {
        if searchService == nil {
            searchService = SearchService(requestHandler: RequestHandler())
        }
        
        let query = page == 1 ? searchQuery : lastQuery
        
        if page == 1 {
            lastQuery = query
            self.personDetails!.posts = []
            self.personDetails!.comments = []
        }
        
        searchService?.search(person: person, query: query, searchType: selectedBrowseOption == browseOptions[0] ? .comments : .posts, page: page) { result in
            switch result {
            case .success(let searchResponse):
                self.personDetails!.posts += searchResponse.posts.filter { !self.personDetails!.posts.contains($0) }
                self.personDetails!.comments += searchResponse.comments.filter { !self.personDetails!.comments.contains($0) }
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadLikedPosts() {
        if page == 1 {
            self.personDetails!.posts = []
        }
        
        let limit = 10
        let startIndex = (page - 1) * limit
        let endIndex = page * limit - 1
        
        for id in SessionStorage.getInstance.getCurrentSession()!.likedPosts[startIndex...endIndex] {
            postService!.getPost(id: id) { result in
                switch result {
                case .success(let postResponse):
                    self.personDetails!.posts += [ postResponse.postView ]
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        page += 1
    }
}

struct SessionPickerOption: Hashable {
    let title: String
    let sessionInfo: SessionInfo?
}
