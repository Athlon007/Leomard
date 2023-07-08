//
//  FeedView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct FeedView: View {
    let sessionService: SessionService
    let contentView: ContentView
    @Binding var myself: MyUserInfo?
    
    let sortTypes: [SortType] = [ .topHour, .topDay, .topMonth, .topYear, .hot, .active, .new, .mostComments ]
    
    @State var selectedListing: ListingType = UserPreferences().listType
    @State var selectedSort: SortType = UserPreferences().postSortMethod
    @State var postsResponse: GetPostsResponse = GetPostsResponse()
    
    @State var page: Int = 1
    @State var postService: PostService? = nil
    
    @State var isLoadingPosts: Bool = false
    
    @Binding var siteView: SiteView?

    var body: some View {
        HStack {
            HStack {
                Image(systemName: selectedListing.image)
                    .padding(.trailing, 0)
                Picker("", selection: $selectedListing) {
                    ForEach(ListingType.allCases, id: \.self) { method in
                        Text(String(describing: method))
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: selectedListing) { value in
                    self.reload()
                    self.loadPosts()
                }
            }
            HStack {
                Image(systemName: selectedSort.image)
                    .padding(.trailing, 0)
                Picker("", selection: $selectedSort) {
                    ForEach(sortTypes, id: \.self) { method in
                        Text(String(describing: method))
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: selectedSort) { value in
                    self.reload()
                    self.loadPosts()
                }
            }
            Button(action: reload) {
                Image(systemName: "arrow.clockwise")
            }
        }
        .frame(
            minWidth: 0,
            idealWidth: .infinity
        )
        VStack {
            GeometryReader { proxy in
                HStack {
                    ScrollViewReader { scrollProxy in
                        List {
                            ForEach(postsResponse.posts, id: \.self) { postView in
                                PostUIView(postView: postView, shortBody: true, postService: self.postService!, myself: $myself, contentView: contentView)
                                    .onAppear {
                                        if postView == self.postsResponse.posts.last {
                                            self.loadPosts()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                Spacer()
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    }
                    
                    if proxy.size.width > 1000 {
                        List {
                            VStack {
                                if siteView != nil {
                                    PageSidebarUIView(siteView: $siteView)
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
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
        .cornerRadius(4)
        .task {
            self.postService = PostService(requestHandler: RequestHandler(sessionService: self.sessionService), sessionService: sessionService)
            loadPosts()
        }
        Spacer()
    }
    
    func loadPosts() {
        if self.isLoadingPosts {
            return
        }
        
        self.isLoadingPosts = true
        if self.postsResponse.posts == [] {
            self.page = 1
        } else {
            self.page += 1
        }
        
        postService!.getAllPosts(page: self.page, sortType: self.selectedSort, listingType: self.selectedListing) { result in
            switch result {
            case .success(let postsResponse) :
                self.postsResponse.posts += postsResponse.posts
                self.isLoadingPosts = false
            case .failure(let error):
                print(error)
                self.isLoadingPosts = false
            }
        }
    }
    
    func reload() {
        self.postsResponse.posts.removeAll()
        loadPosts()
    }
}
