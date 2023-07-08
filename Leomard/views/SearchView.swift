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
    let sessionService: SessionService
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
    
    var body: some View {
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
                    }
                HStack {
                    Picker("", selection: $selectedSearchType) {
                        ForEach(availableSearchTypes, id: \.self) { method in
                            Text(String(describing: method))
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .onChange(of: selectedSearchType) { value in
                        self.page = 1
                        self.search()
                    }
                }
                .padding()
            }
            Spacer()
        }
        .frame(
            minWidth: 0,
            idealWidth: .infinity
        )
        .padding(.leading)
        .padding(.trailing)
        VStack {
            HStack {
                ScrollViewReader { scrollProxy in
                    if self.searching && page == 1 {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    
                    switch selectedSearchType {
                    case .comments:
                        if searchResponse.comments == [] && !self.searching {
                            Text("No comments found!")
                                .italic()
                                .foregroundColor(.secondary)
                        }
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
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    case .communities:
                        if searchResponse.communities == [] && !self.searching {
                            Text("No communities found!")
                                .italic()
                                .foregroundColor(.secondary)
                        }
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
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    default:
                        if searchResponse.posts == [] && !self.searching {
                            Text("No posts found!")
                                .italic()
                                .foregroundColor(.secondary)
                        }
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
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
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
            .cornerRadius(4)
            Spacer()
        }
        .task {
            self.searchQuery = ""
            self.selectedSearchType = .communities
            
            let requestHandler = RequestHandler(sessionService: sessionService)
            self.searchService = SearchService(requestHandler: requestHandler, sessionService: sessionService)
        }
    }
    
    func search() {
        if self.searchQuery == "" {
            return
        }
        
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
                self.searchResponse.communities += searchResponse.communities
                self.searchResponse.comments += searchResponse.comments
                self.searchResponse.posts += searchResponse.posts
                self.searchResponse.users += searchResponse.users
                self.page += 1
                self.searching = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadPostFromComment(commentView: CommentView) {
        
    }
}
