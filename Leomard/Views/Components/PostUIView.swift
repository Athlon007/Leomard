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
    @State private var postBodyMarkdownContent: MarkdownContent? = nil
    @State var url: URL? = nil
    @State var updatedTimeAsString: String = ""
    
    @State var showConfirmDelete: Bool = false
    
    @State var gifHeight: CGFloat = 400
    
    // Height retention variables
    @State var titleHeight: CGFloat = 0
    @State var bodyHeight: CGFloat = 0
    @State var imageHeight: CGFloat = 0
    
    @State private var performedTasksWillAppear = false
    @State var showFailedToFeatureAlert: Bool = false
    
    @State var startRemovePost: Bool = false
    @State var removalReason: String = ""
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if !postView.post.deleted && !postView.post.removed {
            HStack {
                if UserPreferences.getInstance.usePostCompactView && shortBody {
                    compactViewVotes
                    compactViewPreview
                }
                LazyVStack {
                    postTitle
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    if UserPreferences.getInstance.usePostCompactView {
                        if !shortBody {
                            postBodyMarkdown
                            postBodyContent
                        }
                    } else {
                        postBodyMarkdown
                        postBodyContent
                    }
                    Spacer(minLength: 6)
                    if UserPreferences.getInstance.usePostCompactView && shortBody {
                        HStack {
                            communityPersonDate
                                .frame (
                                    alignment: .leading
                                )
                            postActionsToolbar
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                        }
                    } else {
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
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: UserPreferences.getInstance.usePostCompactView ? 0 : titleHeight + bodyHeight + imageHeight,
                    maxHeight: .infinity,
                    alignment: .top
                )
                
                .task {
                    if performedTasksWillAppear == false {
                        performedTasksWillAppear = true
                        postBody = await postBodyTask()
                        postBodyMarkdownContent = await postBodyMarkdownContentTask()
                        url = await postUrlTask()
                        updatedTimeAsString = await updatedTimeAsStringTask()
                        
                        if let vote = postView.myVote, vote > 0 {
                            _ = SessionStorage.getInstance.addLikedPost(post: postView.post)
                        }
                    }
                }
                .alert("Featured Fail", isPresented: $showFailedToFeatureAlert, actions: {
                    Button("OK", action: {})
                }, message: {
                    Text("Failed to feature the post. Try again later.")
                })
            }
            .padding(Self.padding)
            .foregroundColor(getForegroundColor())
            .background(getBackgroundColor())
            .cornerRadius(Self.cornerRadius)
            .onTapGesture {
                if !shortBody {
                    return
                }
                self.contentView.openPost(postView: self.postView)
            }
            .contextMenu {
                PostContextMenu(contentView: contentView, postView: self.postView, sender: self)
            }
            .alert("Remove Post (Mod)", isPresented: $startRemovePost, actions: {
                TextField("Optional", text: $removalReason)
                Button("Remove", role: .destructive) {
                    self.postService.remove(post: postView.post, reason: removalReason, removed: true) { result in
                        switch result {
                        case .success(let postResponse):
                            self.postView = postResponse.postView
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("State the reason of removal:")
            })
            .onDisappear {
                markPostAsReadOnDisapper()
            }
        }
    }
    
    nonisolated
    private func postBodyMarkdownContentTask() async -> MarkdownContent? {
        return await withCheckedContinuation { continuation in
            Task(priority: .background) {
                if let body = await self.postBody {
                    let content = MarkdownContent(body)
                    continuation.resume(returning: content)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    nonisolated
    private func postBodyTask() async -> String? {
        return await withCheckedContinuation { continuation in
            Task(priority: .background) {
                var newPostBody = await self.postView.post.body
                if newPostBody != nil {
                    if shortBody && newPostBody!.count > PostUIView.maxPostLength {
                        newPostBody = String(newPostBody!.prefix(PostUIView.maxPostLength))
                        newPostBody = newPostBody!.trimmingCharacters(in: .whitespacesAndNewlines)
                        newPostBody = newPostBody! + "...\n\n**Read More**"
                    }
                    
                    newPostBody = await newPostBody!.formatMarkdown()
                }
                return continuation.resume(returning: newPostBody)
            }
        }
    }
    
    nonisolated
    private func postUrlTask() async -> URL? {
        return await withCheckedContinuation { continuation in
            Task(priority: .background) {
                guard let postUrl = await self.postView.post.url else {
                    return continuation.resume(returning: nil)
                }
                return continuation.resume(returning: URL(string: postUrl))
            }
        }
    }
    
    nonisolated
    private func updatedTimeAsStringTask() async -> String {
        return await withCheckedContinuation { continuation in
            Task(priority: .background) {
                guard let updatedDate = await self.postView.post.updated else {
                    return continuation.resume(returning: "")
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = dateFormatter.string(from: updatedDate)
                return continuation.resume(returning: dateString)
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
            if postView.post.locked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.green)
            }
            Text(postView.post.name.htmlDecoded)
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
        Markdown(postBodyMarkdownContent ?? .init(""))
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
            .markdownTextStyle(\.text, textStyle: {
                ForegroundColor(getForegroundColor())
            })
            .markdownTextStyle(\.link, textStyle: {
                ForegroundColor(getLinkColor())
            })
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
            WebVideoPlayer(link: postView.post.embedVideoUrl!, imageHeight: $gifHeight)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var articleView: some View {
        VStack {
            Spacer()
            staticImage(postView.post.thumbnailUrl) { image in
                image
                    .resizable()
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
            }.onDisappear(.cancel)
        }
    }
    
    @ViewBuilder
    private var gifOrImage: some View {
        if LinkHelper.isVideosLink(link: postView.post.url!) {
            // Video
            WebVideoPlayer(link: postView.post.url!, imageHeight: $gifHeight)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
        } else if LinkHelper.isAnimatedLink(link: postView.post.url!) {
            // Image-only view.
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
                    .frame(minWidth:0, maxWidth: !shortBody ? 600 : .infinity, maxHeight: .infinity, alignment: .leading)
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
            Group {
                if !UserPreferences.getInstance.usePostCompactView {
                    Text("in")
                }
                CommunityAvatar(community: postView.community)
                Text(UserPreferences.getInstance.preferDisplayNameCommunityPost ? self.postView.community.title : self.postView.community.name)
                    .fontWeight(.semibold)
            }
            .onTapGesture {
                self.contentView.openCommunity(community: postView.community)
            }
            Group {
                Text("by")
                PersonDisplay(person: postView.creator, myself: $myself, defaultForegroundColor: getForegroundColor())
                    .onTapGesture {
                        self.contentView.openPerson(profile: postView.creator)
                    }
            }
            DateDisplayView(date: self.postView.post.published)
            if postView.post.updated != nil {
                Image(systemName: "pencil")
                    .help(updatedTimeAsString)
            }
        }.padding(.vertical, 2)
    }
    
    /// Upvote, downvote, reply, bookmark, etc.
    @ViewBuilder
    private var postActionsToolbar: some View {
        HStack {
            if !(shortBody && UserPreferences.getInstance.usePostCompactView) {
                HStack {
                    Image(systemName: "arrow.up")
                    Text(String(postView.counts.upvotes))
                }
                .foregroundColor(postView.myVote != nil && postView.myVote! > 0 ? .orange : getForegroundColor())
                .onTapGesture {
                    likePost()
                }
                HStack {
                    Image(systemName: "arrow.down")
                    Text(String(postView.counts.downvotes))
                }
                .foregroundColor(postView.myVote != nil && postView.myVote! < 0 ? .blue : getForegroundColor())
                .onTapGesture {
                    dislikePost()
                }
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
                    .foregroundColor(getForegroundColor())
                    Button(action: { showConfirmDelete = true }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.link)
                    .foregroundColor(getForegroundColor())
                    .alert("Confirm", isPresented: $showConfirmDelete, actions: {
                        Button("Delete", role: .destructive) { deletePost() }
                        Button("Cancel", role: .cancel) {}
                    }, message: {
                        Text("Are you sure you want to delete a post?")
                    })
                }
                Button(action: crossPost) {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                }
                .help("Cross-Post")
                .buttonStyle(.link)
                .foregroundColor(getForegroundColor())
                HStack {
                    Image(systemName: "bookmark")
                }
                .frame(alignment: .trailing)
                .foregroundColor(postView.saved ? .green : getForegroundColor())
                .onTapGesture {
                    savePost()
                }
            }
        }
    }
    
    @ViewBuilder
    private var compactViewVotes: some View {
        VStack {
            Image(systemName: "arrow.up")
                .foregroundColor(postView.myVote != nil && postView.myVote! > 0 ? .orange : getForegroundColor())
                .onTapGesture {
                    likePost()
                }
                .font(Font.headline.weight(.bold))
            Text(String(postView.counts.upvotes - postView.counts.downvotes))
            Image(systemName: "arrow.down")
                .foregroundColor(postView.myVote != nil && postView.myVote! < 0 ? .blue : getForegroundColor())
                .onTapGesture {
                    dislikePost()
                }
                .font(Font.headline.weight(.bold))
        }
    }
    
    @ViewBuilder
    private var compactViewPreview: some View {
        if let url = postView.post.url {
            if LinkHelper.isImageLink(link: url) {
                compactViewImage
            } else if LinkHelper.isYouTubeLink(link: url) {
                compactViewVideoThumbnail
            } else if let thumbnail = postView.post.thumbnailUrl, LinkHelper.isImageLink(link: thumbnail) {
                compactViewArticleThumbnail
            }
        }
    }
    
    @ViewBuilder
    private var compactViewImage: some View {
        VStack {
            LazyImage(url: URL(string: postView.post.url!)!) { result in
                if let image = result.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: (postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
        }
        .frame(width: 40, height: 40, alignment: .leading)
        .cornerRadius(4)
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }
    
    @ViewBuilder
    private var compactViewVideoThumbnail: some View {
        VStack {
            LazyImage(url: URL(string: postView.post.thumbnailUrl!)!) { result in
                if let image = result.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: (postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
        }
        .frame(width: 40, height: 40, alignment: .leading)
        .cornerRadius(4)
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .overlay {
            ZStack {
                Color(.black)
                    .opacity(0.33)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
            }
            .cornerRadius(4)
        }
    }
    
    @ViewBuilder
    private var compactViewArticleThumbnail: some View {
        VStack {
            LazyImage(url: URL(string: postView.post.thumbnailUrl!)!) { result in
                if let image = result.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: (postView.post.nsfw || postView.community.nsfw) && UserPreferences.getInstance.blurNsfw && shortBody ? PostUIView.blurStrength : 0)
        }
        .frame(width: 40, height: 40, alignment: .leading)
        .cornerRadius(4)
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            ZStack {
                Color(.black)
                    .opacity(0.33)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Image(systemName: "newspaper.fill")
                    .foregroundColor(.white)
            }
            .cornerRadius(4)
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
                if UserPreferences.getInstance.markPostAsReadOnVote {
                    markAsRead(true)
                }
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
                if UserPreferences.getInstance.markPostAsReadOnVote {
                    markAsRead(true)
                }
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
    
    func featureCommunity() {
        postService.feature(post: postView.post, featureType: .community, featured: !postView.post.featuredCommunity) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
                showFailedToFeatureAlert = true
            }
        }
    }
    
    func markAsRead(_ read: Bool) {
        if read == postView.read {
            return
        }
        
        postService.markAsRead(post: postView.post, read: read) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
                // TODO: Show error
            }
        }
    }
    
    func crossPost() {
        contentView.openCrossPost(post: postView)
    }
    
    func startPostRemoval() {
        startRemovePost = true
    }
    
    func lock() {
        postService.lock(post: postView.post, locked: !postView.post.locked) { result in
            switch result {
            case .success(let postResponse):
                self.postView = postResponse.postView
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func markPostAsReadOnDisapper() {
        if UserPreferences.getInstance.markPostAsReadOnDisappear && !postView.read {
            self.postService.markAsRead(post: postView.post, read: true) { _ in
                print("post \(postView.post.name) marked as read")
                postView.read = true
            }
        }
    }
    
    func getBackgroundColor() -> Color {
        if UserPreferences.getInstance.twoColumnView && shortBody {
            return self.contentView.openedPostView == self.postView ? Color(.selectedContentBackgroundColor) : Color(.textBackgroundColor)
        }
        
        return Color(.textBackgroundColor)
    }
    
    func getForegroundColor() -> Color {
        if UserPreferences.getInstance.twoColumnView && shortBody {
            return self.contentView.openedPostView == self.postView ? Color(.white) : Color(.textColor)
        }
        
        return Color(.textColor)
    }
    
    func getLinkColor() -> Color {
        if UserPreferences.getInstance.twoColumnView && shortBody {
            return self.contentView.openedPostView == self.postView ? Color(red: 185, green: 245, blue: 96) : Color(.linkColor)
        }
        
        return Color(.linkColor)
    }
}
