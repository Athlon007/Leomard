//
//  SearchView.swift
//  Leomard
//
//  Created by Konrad Figura on 07/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct SearchView: View {
    let postService: PostService
    let commentService: CommentService
    let contentView: ContentView
    @Binding var myself: MyUserInfo?

    @State var searchService: SearchService?

    @State var searchResponse: SearchResponse = SearchResponse()

    @State var searchQuery: String = ""
    @State var selectedSearchType: SearchType = .communities
    let availableSearchTypes: [SearchType] = [ .communities, .posts, .comments, .users ]

    @State var searching: Bool = false
    @State var page: Int = 1
    @State var searchedOnce: Bool = false
    @FocusState var searchFocused: Bool
    @State var error: String = ""

    var body: some View {
        searchBar
            .frame(
                minWidth: 0,
                idealWidth: .infinity
            )
            .padding(.leading)
            .padding(.trailing)
            .task {
                searchFocused = true
            }
        VStack {
            HStack {
                ScrollViewReader { _ in
                    searchProgressView(visible: self.searching && page == 1)
                    searchResultsList(selectedSearchType: selectedSearchType)
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
            .cornerRadius(4)
            Spacer()
        }
        .task {
            self.searchQuery = ""
            self.selectedSearchType = .communities

            let requestHandler = RequestHandler()
            self.searchService = SearchService(requestHandler: requestHandler)
        }
    }
    
    // MARK: - Search Form
    
    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Spacer()
            VStack {
                TextField("Search", text: $searchQuery)
                    .frame(
                        minWidth: 0,
                        maxWidth: 600
                    )
                    .onSubmit {
                        self.page = 1
                        self.search()
                        searchFocused = false
                    }
                    .focused($searchFocused)
                HStack {
                    Picker("", selection: $selectedSearchType) {
                        ForEach(availableSearchTypes, id: \.self) { method in
                            Text(String(describing: method))
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .onChange(of: selectedSearchType) { _ in
                        self.page = 1
                        self.search()
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
    
    // MARK: - Search Results
    
    @ViewBuilder
    private func searchProgressView(visible: Bool) -> some View {
        if visible {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
    
    @ViewBuilder
    private func searchResultsList(selectedSearchType: SearchType) -> some View {
        switch selectedSearchType {
        case .comments:
            commentsList
        case .communities:
            communitiesList
        case .users:
            usersList
        default:
            postsList
        }
    }
    
    @ViewBuilder
    private var commentsList: some View {
        if searchResponse.comments == [] && !self.searching && self.searchedOnce {
            Text("No comments found!")
                .italic()
                .foregroundColor(.secondary)
            if self.error != "" {
                Text(self.error)
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            List {
                ForEach(searchResponse.comments, id: \.self) { commentView in
                    VStack {
                        CommentUIView(commentView: commentView, indentLevel: 1, commentService: commentService, myself: $myself, post: commentView.post, contentView: contentView)
                            .onAppear {
                                if commentView == searchResponse.comments.last {
                                    self.search()
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
            }
        }
    }
    
    @ViewBuilder
    private var communitiesList: some View {
        if searchResponse.communities == [] && !self.searching && self.searchedOnce {
            Text("No communities found!")
                .italic()
                .foregroundColor(.secondary)
            if self.error != "" {
                Text(self.error)
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            List {
                ForEach(searchResponse.communities, id: \.self) { communityView in
                    VStack {
                        CommunitySearchUIView(communityView: communityView, contentView: contentView)
                            .onAppear {
                                if communityView == searchResponse.communities.last {
                                    self.search()
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
                    Spacer()
                        .frame(height: 0)
                    
                }
            }
        }
    }
    
    @ViewBuilder
    private var usersList: some View {
        if searchResponse.users == [] && !self.searching && self.searchedOnce {
            Text("No users found!")
                .italic()
                .foregroundColor(.secondary)
            if self.error != "" {
                Text(self.error)
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            List {
                ForEach(searchResponse.users, id: \.self) { personView in
                    VStack {
                        UserSearchUIView(personView: personView, contentView: contentView)
                            .onAppear {
                                if personView == searchResponse.users.last {
                                    self.search()
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
                    Spacer()
                        .frame(height: 0)
                    
                }
            }
        }
    }
    
    @ViewBuilder
    private var postsList: some View {
        if searchResponse.posts == [] && !self.searching && self.searchedOnce {
            Text("No posts found!")
                .italic()
                .foregroundColor(.secondary)
            if self.error != "" {
                Text(self.error)
                    .italic()
                    .foregroundColor(.secondary)
            }
        } else {
            List {
                ForEach(searchResponse.posts, id: \.self) { postView in
                    PostUIView(postView: postView, shortBody: true, postService: self.postService, myself: $myself, contentView: contentView)
                        .onAppear {
                            if postView == searchResponse.posts.last {
                                self.search()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                        .frame(height: 0)
                }
            }
        }
    }
    
    // MARK: -

    func search() {
        if self.searchQuery == "" {
            return
        }
        
        self.error = ""
        
        self.searchedOnce = true

        if page == 1 {
            self.searchResponse.communities = []
            self.searchResponse.comments = []
            self.searchResponse.posts = []
            self.searchResponse.users = []
        }

        self.searching = true

        searchService!.search(query: self.searchQuery, searchType: self.selectedSearchType, page: self.page) { result in
            switch result {
            case .success(let searchResponse):
                self.searchResponse.communities += searchResponse.communities.filter { !searchResponse.communities.contains($0) }
                self.searchResponse.comments += searchResponse.comments.filter { !searchResponse.comments.contains($0) }
                self.searchResponse.posts += searchResponse.posts.filter { !searchResponse.posts.contains($0) }
                self.searchResponse.users += searchResponse.users.filter { !searchResponse.users.contains($0) }
                self.page += 1
                self.searching = false
            case .failure(let error):
                print(error)
                self.searching = false
                if let errorResponse = error as? ErrorResponse {
                    self.error = errorResponse.error
                } else {
                    self.error = "Your Lemmy instance is down, or took to long to respond. Try again later."
                }
            }
        }
    }
    
    func loadPostFromComment(commentView: CommentView) {
        self.contentView.openPostForComment(comment: commentView.comment)
    }
}
