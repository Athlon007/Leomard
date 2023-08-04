//
//  CommunityView.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation
import SwiftUI

struct CommunityUIView: View {
    @State var community: Community
    let postService: PostService
    let commentService: CommentService
    let contentView: ContentView
    @State var myself: MyUserInfo?
    @Binding var showDismissInCommunityView: Bool
    
    let sortTypes: [SortType] = [ .topHour, .topDay, .topMonth, .topYear, .hot, .active, .new, .mostComments ]
    @State var browseOptions: [Option] = [
        .init(id: 0, title: "Posts", imageName: "doc.plaintext"),
        .init(id: 1, title: "Comments", imageName: "message")
    ]
    
    @State var communityService: CommunityService?
    @State var searchService: SearchService?
    
    @State var selectedSortType: SortType = .active
    @State var selectedBrowseOption: Option = Option(id: 0, title: "Posts", imageName: "doc.plaintext")
    
    @State var communityResponse: GetCommunityResponse?
    @State var posts: [PostView] = []
    @State var comments: [CommentView] = []
    @State var page: Int = 1
    
    @State var searchVisible: Bool = false
    @State var searchQuery: String = ""
    @State var lastQuery: String = ""
    @State var showSearchPosts: Bool = false
    
    @State var isLoading: Bool = false
    
    @State var showCommunityEdit: Bool = false
    @State var title: String = ""
    @State var description: String = ""
    @State var nsfw: Bool = false
    @State var postingRestrictedToMods: Bool = false
    @State var communityUpdateFail: Bool = false
    
    @State var showCommunityRemove: Bool = false
    @State var communityRemoved: Bool = false
    @State var communityRemoveText: String = ""
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        toolbar
            .frame(
                minWidth: 0,
                idealWidth: .infinity
            )
            .padding(.leading)
            .padding(.trailing)
        VStack {
            GeometryReader { proxy in
                HStack {
                    communityContent(
                        communityResponse,
                        sidebarVisible: proxy.size.width < 1000)
                    communitySidebar(visible: proxy.size.width > 1000)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
        .overlay(communityEditor)
        .overlay(removeCommunityOverlay)
        .cornerRadius(8)
        .task {
            let requestHandler = RequestHandler()
            self.communityService = CommunityService(requestHandler: requestHandler)
            self.selectedBrowseOption = browseOptions[0]
            loadCommunity()
        }
        
        .alert("Community Removed", isPresented: $communityRemoved, actions: {
            Button("OK", action: {})
        }, message: {
            Text("Community has been removed successfully.")
        })
        Spacer()
    }
    
    // MARK: -
    
    @ViewBuilder
    private var removeCommunityOverlay: some View {
        if showCommunityRemove {
            ZStack {
                Color(white: 0, opacity: 0.33)
                    .onTapGesture {
                        showCommunityEdit = false
                    }
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        Image(nsImage: NSApplication.shared.applicationIconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        Text("Remove Community")
                            .bold()
                            .font(.title2)
                    }
                    .padding()
                    VStack(alignment: .center) {
                        Text("Are you really, REALLY sure you want to remove this community? To remove the community, type the following:\n")
                        Text("**Yes, remove \(community.name)@\(LinkHelper.stripToHost(link: community.actorId)) community.**")
                            .frame(alignment: .center)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    TextField("", text: $communityRemoveText)
                    HStack(alignment: .center) {
                        Button("Remove Community") {
                            communityService?.remove(community: community, removed: true) { result in
                                switch result {
                                case .success(_):
                                    communityRemoved = true
                                case .failure(let error):
                                    print(error)
                                }
                            }
                            showCommunityRemove = false
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                        .disabled(communityRemoveText != "Yes, remove \(community.name)@\(LinkHelper.stripToHost(link: community.actorId)) community.")
                        Button("Cancel") {
                            showCommunityRemove = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color(.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
                .task {
                    communityRemoveText = ""
                }
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: -
    
    @ViewBuilder
    private func communityContent(_ communityResponse: GetCommunityResponse?, sidebarVisible: Bool) -> some View {
        List {
            if let communityResponse {
                if sidebarVisible {
                    VStack {
                        CommunityUISidebarView(
                            communityResponse: communityResponse,
                            communityService: communityService!,
                            contentView: contentView,
                            myself: $myself,
                            onPostAdded: addNewPost,
                            onEditCommunity: {
                                showCommunityEdit = true
                            },
                            onRemoveCommunity: {
                                showCommunityRemove = true
                            })
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .cornerRadius(8)
                    .padding(.bottom, 15)
                }
                switch selectedBrowseOption.id {
                case 1:
                    commentsList
                default:
                    postsList
                }
                
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: 600,
            maxHeight: .infinity,
            alignment: .center
        )
    }
    
    @ViewBuilder
    private func communitySidebar(visible: Bool) -> some View {
        if visible {
            List {
                VStack {
                    if communityResponse != nil {
                        CommunityUISidebarView(communityResponse: communityResponse!, communityService: communityService!, contentView: contentView, myself: $myself, onPostAdded: addNewPost, onEditCommunity: {
                            showCommunityEdit = true
                        },
                                               onRemoveCommunity: {
                            showCommunityRemove = true
                        })
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity
                )
                .cornerRadius(8)
            }
            .frame(
                minWidth: 0,
                maxWidth: 400,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
    
    @ViewBuilder
    private var commentsList: some View {
        if self.comments == [] {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            } else {
                Text("No comments found!")
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            ForEach(comments, id: \.self) { commentView in
                VStack {
                    CommentUIView(commentView: commentView, indentLevel: 1, commentService: commentService, myself: $myself, post: commentView.post, contentView: contentView)
                        .onAppear {
                            if commentView == comments.last {
                                self.loadComments()
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
            .frame(
                minWidth: 0,
                maxWidth: 600,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
    
    @ViewBuilder
    private var postsList: some View {
        if self.posts == [] {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            } else {
                Text("No posts found!")
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            ForEach(posts, id: \.self) { postView in
                PostUIView(postView: postView, shortBody: true, postService: self.postService, myself: $myself, contentView: contentView)
                    .onAppear {
                        if postView == self.posts.last {
                            self.loadPosts()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                    .frame(height: 0)
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ViewBuilder
    private var toolbar: some View {
        HStack {
            if showDismissInCommunityView {
                Button("Dismiss", action: contentView.dismissCommunity)
                    .buttonStyle(.link)
            }
            Spacer()
            HStack(alignment: .center) {
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
                }
                HStack {
                    Image(systemName: selectedSortType.image)
                        .padding(.trailing, 0)
                    Picker("", selection: $selectedSortType) {
                        ForEach(sortTypes, id: \.self) { method in
                            Text(String(describing: method).spaceBeforeCapital())
                        }
                    }
                    .frame(maxWidth: 120)
                    .padding(.leading, -10)
                    .onChange(of: selectedSortType) { value in
                        self.reloadFeed()
                    }
                }
                Button(action: reloadFeed) {
                    Image(systemName: "arrow.clockwise")
                }
            }.disabled(searchVisible)
            Spacer()
            HStack {
                if searchVisible {
                    TextField("Search", text: $searchQuery)
                        .frame(maxWidth: 200)
                        .onSubmit {
                            search()
                        }
                        .cornerRadius(8)
                }
                Button(action: toggleSearch) {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.link)
            }
        }
    }
    
    @ViewBuilder
    private var communityEditor: some View {
        if showCommunityEdit {
            ZStack {
                Color(white: 0, opacity: 0.33)
                    .onTapGesture {
                        showCommunityEdit = false
                    }
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button("Dismiss", action: { showCommunityEdit = false })
                                .buttonStyle(.link)
                            Spacer()
                            Button("Change More Settings", action: {
                                self.openURL(URL(string: community.actorId)!)
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
                        
                        List {
                            VStack(alignment: .leading) {
                                Text("Display Name")
                                    .bold()
                                TextField("Optional", text: $title)
                            }
                            VStack(alignment: .leading) {
                                Text("Description")
                                    .bold()
                                MarkdownEditor(bodyText: $description, contentView: self.contentView)
                                    .frame(maxHeight: .infinity)
                            }
                            VStack(alignment: .leading) {
                                Toggle("NSFW", isOn: $nsfw)
                                Toggle("Posting Restricted To Moderators", isOn: $postingRestrictedToMods)
                            }
                            VStack(alignment: .leading) {
                                Button("Save Changes", action: {
                                    saveCommunitySettings()
                                })
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .task {
                            self.title = community.title
                            self.description = community.description ?? ""
                            self.nsfw = community.nsfw
                            self.postingRestrictedToMods = community.postingRestrictedToMods
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .frame(maxWidth: 600, maxHeight: 600)
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
            }
            .alert("Community Update Failure", isPresented: $communityUpdateFail, actions: {
                Button("OK") {}
            }, message: {
                Text("Failed to update the community. Try again later.")
            })
        }
    }
    
    // MARK: -
    
    func loadCommunity() {
        isLoading = true
        self.communityService?.getCommunity(id: self.community.id) { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.communityResponse = response
                // Load posts (as that's our default)
                loadPosts()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadPosts() {
        if showSearchPosts {
            self.search()
            return
        }
        
        isLoading = true
        
        self.postService.getPostsForCommunity(community: self.communityResponse!.communityView.community, page: page) { result in
            isLoading = false
            switch result {
            case .success(let postsResponse):
                self.posts += postsResponse.posts.filter { !self.posts.contains($0) }
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadComments() {
        isLoading = true
        self.commentService.getCommentsForCommunity(community: self.communityResponse!.communityView.community, page: page) { result in
            isLoading = false
            switch result {
            case .success(let commentsResponse):
                self.comments += commentsResponse.comments.filter { !self.comments.contains($0) }
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func reloadFeed() {
        page = 1
        self.posts = []
        self.comments = []
        
        if selectedBrowseOption.id == 0 {
            loadPosts()
        } else {
            loadComments()
        }
    }
    
    func loadPostFromComment(commentView: CommentView) {
        self.postService.getPostForComment(comment: commentView.comment) { result in
            switch result {
            case .success(let getPostResponse):
                self.contentView.openPost(postView: getPostResponse.postView)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addNewPost(postView: PostView) {
        DispatchQueue.main.async {
            self.posts.insert(postView, at: 0)
        }
    }
    
    func toggleSearch() {
        searchVisible = !searchVisible
        
        if !searchVisible && showSearchPosts {
            page = 1
            showSearchPosts = false
            posts.removeAll()
            loadPosts()
        }
        
        if searchVisible {
            searchQuery = ""
        }
    }
    
    func search() {
        if self.searchService == nil {
            self.searchService = SearchService(requestHandler: RequestHandler())
        }
        
        isLoading = true
        
        if !showSearchPosts || searchQuery != lastQuery {
            showSearchPosts = true
            page = 1
            selectedBrowseOption = browseOptions[0]
            lastQuery = searchQuery
            self.posts.removeAll()
        }
        
        self.searchService!.search(community: community, query: searchQuery, searchType: .posts, page: page) { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.posts += response.posts.filter { !self.posts.contains($0) }
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func saveCommunitySettings() {
        communityService?.edit(community: community, displayName: title, description: description, nsfw: nsfw, postingRestrictedToMods: postingRestrictedToMods) { result in
            switch result {
            case .success(let communityResponse):
                self.community = communityResponse.communityView.community
            case .failure(let error):
                print(error)
                communityUpdateFail = true
            }
        }
    }
}
