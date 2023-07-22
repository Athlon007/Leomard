//
//  FeedView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

@MainActor
final class FeedViewModel: ObservableObject {
    
    @Published var selectedListing: ListingType = UserPreferences.getInstance.listType
    @Published var selectedSort: SortType = UserPreferences.getInstance.postSortMethod
  
    @Published private(set) var isLoadingPosts = false
    
    let postService: PostService = .init(requestHandler: RequestHandler())
    @Published private(set) var page: Int = 1
    @Published var postsResponse: GetPostsResponse = .init()
    
    func loadPosts() {
        if isLoadingPosts {
            return
        }
        
        isLoadingPosts = true
        if postsResponse.posts == [] {
            page = 1
        } else {
            page += 1
        }
        
        postService.getAllPosts(
            page: page,
            sortType: selectedSort,
            listingType: selectedListing) { result in
                Task { @MainActor in
                    switch result {
                    case .success(let postsResponse):
                        let initialCount = self.postsResponse.posts.count
                        self.postsResponse.posts += postsResponse.posts.filter { !self.postsResponse.posts.contains($0) }
                        self.isLoadingPosts = false
                        if initialCount == self.postsResponse.posts.count {
                            // No posts were added. Call loadPosts() again.
                            self.loadPosts()
                        }
                    case .failure(let error):
                        print(error)
                        self.isLoadingPosts = false
                    }
                }
            }
    }
    
    func reload() {
        postsResponse.posts.removeAll()
        loadPosts()
    }
}

struct FeedView: View {
    let contentView: ContentView
    @Binding var myself: MyUserInfo?
    
    let sortTypes: [SortType] = [ .topHour, .topDay, .topMonth, .topYear, .hot, .active, .new, .mostComments ]
    
    @StateObject private var viewModel: FeedViewModel = .init()
    
    @Binding var siteView: SiteView?

    var body: some View {
        feedToolbar
            .frame(
                minWidth: 0,
                idealWidth: .infinity
            )
        feedContent
            .cornerRadius(8)
            .task {
                viewModel.loadPosts()
            }
            .onDisappear {
                viewModel.postsResponse = GetPostsResponse()
            }
        Spacer()
    }
    
    /// For commonly-used button actions like sort and reload.
    @ViewBuilder
    private var feedToolbar: some View {
        HStack {
            HStack {
                Image(systemName: viewModel.selectedListing.image)
                    .padding(.trailing, 0)
                Picker("", selection: $viewModel.selectedListing) {
                    ForEach(ListingType.allCases, id: \.self) { method in
                        Text(String(describing: method))
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: viewModel.selectedListing) { value in
                    viewModel.reload()
                }
            }
            HStack {
                Image(systemName: viewModel.selectedSort.image)
                    .padding(.trailing, 0)
                Picker("", selection: $viewModel.selectedSort) {
                    ForEach(sortTypes, id: \.self) { method in
                        Text(String(describing: method))
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: viewModel.selectedSort) { value in
                    viewModel.reload()
                }
            }
            Button(action: { viewModel.reload() }) {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
    
    @ViewBuilder
    private var feedContent: some View {
        VStack {
            // - TODO: GeometryReader is used to dynamically show/hide site sidebar. This proxy is expensive, could be replaced with `.preference(key...)` view modifier instead?
            GeometryReader { proxy in
                HStack {
                    feedPostsList
                    feedPageSidebar(visible: proxy.size.width > 1000)
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
            }
        }
    }
    
    /// Infinite scrolling view for this feed's content
    @ViewBuilder
    private var feedPostsList: some View {
        // - TODO: `scrollProxy` is expensive and isn't being used, remove?
        ScrollViewReader { scrollProxy in
            if viewModel.isLoadingPosts && viewModel.postsResponse.posts.count == 0 {
                ProgressView().progressViewStyle(.circular).padding(.top, 20)
            }
            List(viewModel.postsResponse.posts, id: \.post.id) { postView in
                PostUIView(
                    postView: postView,
                    shortBody: true,
                    postService: viewModel.postService,
                    myself: $myself,
                    contentView: contentView)
                .onAppear {
                    if postView == viewModel.postsResponse.posts.last {
                        viewModel.loadPosts()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
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
    private func feedPageSidebar(visible: Bool) -> some View {
        if visible {
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
                .cornerRadius(8)
            }
        }
    }
}
