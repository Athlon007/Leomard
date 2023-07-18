//
//  CommunityView.swift
//  Leomard
//
//  Created by Konrad Figura on 06/07/2023.
//

import Foundation
import SwiftUI

struct CommunityUIView: View {
    let community: Community
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
    
    @State var selectedSortType: SortType = .active
    @State var selectedBrowseOption: Option = Option(id: 0, title: "Posts", imageName: "doc.plaintext")
    
    @State var communityResponse: GetCommunityResponse?
    @State var posts: [PostView] = []
    @State var comments: [CommentView] = []
    @State var page: Int = 1
    
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
        .cornerRadius(4)
        .task {
            let requestHandler = RequestHandler()
            self.communityService = CommunityService(requestHandler: requestHandler)
            self.selectedBrowseOption = browseOptions[0]
            loadCommunity()
        }
        Spacer()
    }
    
    // MARK: -
    
    @ViewBuilder
    private func communityContent(_ communityResponse: GetCommunityResponse?, sidebarVisible: Bool) -> some View {
        ScrollViewReader { scrollProxy in
            List {
                if let communityResponse {
                    if sidebarVisible {
                        VStack {
                            CommunityUISidebarView(
                                communityResponse: communityResponse,
                                communityService: communityService!,
                                contentView: contentView,
                                myself: $myself,
                                onPostAdded: addNewPost)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .center
                        )
                        .cornerRadius(4)
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
    }
    
    @ViewBuilder
    private func communitySidebar(visible: Bool) -> some View {
        if visible {
            List {
                VStack {
                    if communityResponse != nil {
                        CommunityUISidebarView(communityResponse: communityResponse!, communityService: communityService!, contentView: contentView, myself: $myself, onPostAdded: addNewPost)
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
    
    @ViewBuilder
    private var commentsList: some View {
        if self.comments == [] {
            Text("No comments found!")
                .italic()
                .foregroundColor(.secondary)
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
                .cornerRadius(4)
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
            Text("No posts found!")
                .italic()
                .foregroundColor(.secondary)
        } else {
            ForEach(posts, id: \.self) { postView in
                PostUIView(postView: postView, shortBody: true, postService: self.postService, myself: $myself, contentView: contentView)
                    .onAppear {
                        if postView == self.posts.last {
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
                }
                HStack {
                    Image(systemName: selectedSortType.image)
                        .padding(.trailing, 0)
                    Picker("", selection: $selectedSortType) {
                        ForEach(sortTypes, id: \.self) { method in
                            Text(String(describing: method))
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
            }
            Spacer()
        }
    }
    
    // MARK: -
    
    func loadCommunity() {
        self.communityService?.getCommunity(id: self.community.id) { result in
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
        self.postService.getPostsForCommunity(community: self.communityResponse!.communityView.community, page: page) { result in
            switch result {
            case .success(let postsResponse):
                self.posts += postsResponse.posts
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadComments() {
        self.commentService.getCommentsForCommunity(community: self.communityResponse!.communityView.community, page: page) { result in
            switch result {
            case .success(let commentsResponse):
                self.comments += commentsResponse.comments
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
}
