//
//  PostView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import Combine
import AVKit
import NukeUI

@MainActor
struct PostUIView: View {
    @State var postView: PostView
    let shortBody: Bool
    let postService: PostService
    @Binding var myself: MyUserInfo?
    let contentView: ContentView
    
    private static let maxPostLength: Int = 400
    private static let blurStrength: CGFloat = 50
    private static let cornerRadius: CGFloat = 8
    private static let padding: CGFloat = 12
    
    @State var postBody: String? = nil
    @State var url: URL? = nil
    @State var updatedTimeAsString: String = ""
    
    @State var showConfirmDelete: Bool = false
    
    @State var gifHeight: CGFloat = 400
    
    // Height retention variables
    @State var titleHeight: CGFloat = 0
    @State var bodyHeight: CGFloat = 0
    @State var imageHeight: CGFloat = 0

    @Environment(\.openURL) var openURL
    
    var body: some View {
        if !postView.post.deleted && !postView.post.removed {
            LazyVStack {
                postTitle
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                postBodyMarkdown
                postBodyContent
                Spacer(minLength: 6)
                communityPersonDate
                    .frame (
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                Spacer(minLength: 6)
                postActionsToolbar
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            }
            .padding(Self.padding)
            .background(Color(.textBackgroundColor))
            .cornerRadius(Self.cornerRadius)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: titleHeight + bodyHeight + imageHeight,
                maxHeight: .infinity,
                alignment: .top
            )
            
            .task {
                self.postBody = self.postView.post.body
                if self.postBody != nil {
                    self.postBody = postBody!.replacingOccurrences(of: "\r", with: "<br>")
                    let regex = try! NSRegularExpression(pattern: #"!\[\]\((.*?)\)"#, options: .caseInsensitive)
                    let range = NSRange(location: 0, length: postBody!.utf16.count)
                    
                    let matches = regex.matches(in: postBody!, options: [], range: range)
                    
                    var imageUrls: [String] = []
                    
                    for match in matches {
                        if let urlRange = Range(match.range(at: 1), in: postBody!) {
                            let imageUrl = String(postBody![urlRange])
                            imageUrls.append(imageUrl)
                        }
                    }
                }
                if shortBody && postBody != nil && postBody!.count > PostUIView.maxPostLength {
                    postBody = String(postBody!.prefix(PostUIView.maxPostLength))
                    postBody = postBody!.trimmingCharacters(in: .whitespacesAndNewlines)
                    postBody = postBody! + "... **Read More**"
                }
                
                if postView.post.url != nil {
                    url = URL(string: postView.post.url!)
                }
                
                if postView.post.updated != nil {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    updatedTimeAsString = dateFormatter.string(from: postView.post.updated!)
                }
            }
            .onTapGesture {
                self.contentView.openPost(postView: self.postView)
            }
            .contextMenu {
                PostContextMenu(postView: self.postView)
            }
        }
    }
    
    // MARK: -
    
    @ViewBuilder
    private var postTitle: some View {
        HStack {
            if postView.post.featuredCommunity {
                Image(systemName: "pin.fill")
                    .foregroundColor(.red)
            }
            Text(postView.post.name)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 24))
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.titleHeight = geometry.size.height
                        }
                })
        }
    }
    
    @ViewBuilder
    private var postBodyMarkdown: some View {
        if let body = self.postBody {
            let content = MarkdownContent(body)
            Markdown(content)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .lineLimit(nil)
                .textSelection(.enabled)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.bodyHeight = geometry.size.height
                        }
                })
        }
    }
    
    @ViewBuilder
    private var postBodyContent: some View {
        if postView.post.embedTitle != nil && postView.post.thumbnailUrl != nil {
            if LinkHelper.isYouTubeLink(link: postView.post.url!) {
                YoutubePlayer(link: postView.post.url!, imageHeight: $gifHeight)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            } else {
                articleView
                    .onTapGesture {
                        openURL(url!)
                    }
            }
        } else if postView.post.url != nil && postView.post.embedTitle == nil {
            gifOrImage
            Spacer()
        } else if postView.post.embedVideoUrl != nil && LinkHelper.isVideosLink(link: postView.post.embedVideoUrl!) {
            VideoPlayer(player: AVPlayer(url: URL(string: postView.post.embedVideoUrl!)!))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var articleView: some View {
        VStack {
            Spacer()
            staticImage(postView.post.thumbnailUrl) { image in
                image
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(4)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                self.imageHeight = geometry.size.height
                            }
                    })
                    .blur(radius:(postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
            }
            .padding(.leading, 4)
            .padding(.trailing, 4)
            .padding(.top, 4)
            if LinkHelper.isWebp(link: postView.post.thumbnailUrl!) {
                Spacer()
            }
            Text(postView.post.url!)
                .foregroundColor(Color(.linkColor))
                .fixedSize(horizontal: false, vertical: false)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
        }
        .background(.ultraThickMaterial)
        .cornerRadius(4)
    }
    
    /// - Parameter imageBlock: Use this to modify the `Image` instance.
    /// - Returns: A wrapper view that contains an `Image` instance.
    @ViewBuilder
    private func staticImage(_ thumbnailUrl: String?, @ViewBuilder imageBlock: @escaping (Image) -> some View) -> some View {
        if let thumbnailUrl {
            LazyImage(url: .init(string: thumbnailUrl), transaction: .init(animation: .easeOut(duration: 0.2))) { state in
                if let image = state.image {
                    imageBlock(image)
                } else if state.error != nil {
                    Link("\(postView.post.url!)", destination: URL(string: postView.post.url!)!)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }.onDisappear(.lowerPriority)
        }
    }
    
    @ViewBuilder
    private var gifOrImage: some View {
        // Image-only view.
        if LinkHelper.isAnimatedLink(link: postView.post.url!) {
            // GIF
            AnimatedImage(link: postView.post.url!, imageHeight: $gifHeight)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
                .blur(radius: (postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
        } else if LinkHelper.isImageLink(link: postView.post.url!) {
            // Static Images
            Spacer()
            Text("")
            if LinkHelper.isWebp(link: postView.post.url!) {
                Spacer()
            }
            staticImage(postView.post.url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth:0, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                self.imageHeight = geometry.size.height
                            }
                    })
            }
            .blur(radius: (postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
            if LinkHelper.isWebp(link: postView.post.url!) {
                Spacer()
            }
        } else {
            // Simple external link.
            let url = URL(string: postView.post.url!)!
            Link(url.absoluteString, destination: url)
        }
    }
    
    @ViewBuilder
    private var communityPersonDate: some View {
        LazyHStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("in")
                CommunityAvatar(community: postView.community)
                Text(self.postView.community.name)
                    .fontWeight(.semibold)
            }
            .onTapGesture {
                self.contentView.openCommunity(community: postView.community)
            }
            HStack(spacing: 4) {
                Text("by")
                PersonDisplay(person: postView.creator, myself: $myself)
                    .onTapGesture {
                        self.contentView.openPerson(profile: postView.creator)
                    }
            }
            DateDisplayView(date: self.postView.post.published)
            if postView.post.updated != nil {
                HStack {
                    Image(systemName: "pencil")
                    
                }.help(updatedTimeAsString)
            }
        }
    }
    
    /// Upvote, downvote, reply, bookmark, etc.
    @ViewBuilder
    private var postActionsToolbar: some View {
        HStack {
            HStack {
                Image(systemName: "arrow.up")
                Text(String(postView.counts.upvotes))
            }
            .foregroundColor(postView.myVote != nil && postView.myVote! > 0 ? .orange : .primary)
            .onTapGesture {
                likePost()
            }
            HStack {
                Image(systemName: "arrow.down")
                Text(String(postView.counts.downvotes))
            }
            .foregroundColor(postView.myVote != nil && postView.myVote! < 0 ? .blue : .primary)
            .onTapGesture {
                dislikePost()
            }
            HStack {
                Image(systemName: "ellipsis.message")
                Text(String(postView.counts.comments))
            }
            Spacer()
            if myself != nil {
                if postView.creator.actorId == myself?.localUserView.person.actorId {
                    Button(action: { startEditPost() } ) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.link)
                    .foregroundColor(.primary)
                    Button(action: { showConfirmDelete = true }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.link)
                    .foregroundColor(.primary)
                    .alert("Confirm", isPresented: $showConfirmDelete, actions: {
                        Button("Delete", role: .destructive) { deletePost() }
                        Button("Cancel", role: .cancel) {}
                    }, message: {
                        Text("Are you sure you want to delete a post?")
                    })
                }
                HStack {
                    Image(systemName: "bookmark")
                }
                .frame(alignment: .trailing)
                .foregroundColor(postView.saved ? .green : .primary)
                .onTapGesture {
                    savePost()
                }
            }
        }
    }
    
    // MARK: -
    
    func likePost() {
        if myself == nil {
            return
        }
        
        var score = 1
        if postView.myVote == 1 {
            score = 0
        }
        self.postService.setPostLike(post: postView.post, score: score) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func dislikePost() {
        if myself == nil {
            return
        }
        
        var score = -1
        if postView.myVote == -1 {
            score = 0
        }
        self.postService.setPostLike(post: postView.post, score: score) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func savePost() {
        let save = !postView.saved
        self.postService.savePost(post: postView.post, save: save) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startEditPost() {
        self.contentView.openPostEdition(post: postView, onPostEdited: onPostEdited)
    }
    
    func deletePost() {
        self.postService.deletePost(post: postView.post, deleted: true) { result in
            switch result {
            case .success(_):
                self.postView.post.deleted = true
                self.contentView.closePost()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func onPostEdited(updatedPostView: PostView) {
        self.postView = updatedPostView
        self.postBody = updatedPostView.post.body
    }
}
