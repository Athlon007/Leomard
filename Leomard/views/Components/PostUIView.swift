//
//  PostView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct PostUIView: View {
    @State var postView: PostView
    let shortBody: Bool
    let postService: PostService
    private static let maxPostLength: Int = 400
    
    @State var postBody: String? = nil
    @State var url: URL? = nil
    
    @State var gifHeight: CGFloat = 400
    
    // Height retention variables
    @State var minimumHeight: CGFloat = 0
    @State var heightSamples: Int = 0
    static let maxHeightSamples: Int = 2
    
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        GeometryReader { reader in
            LazyVStack {
                HStack {
                    if postView.post.featuredCommunity {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.red)
                    }
                    Text(showHeight() + " " + postView.post.name)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 24))
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                if self.postBody != nil {
                    let content = MarkdownContent(self.postBody!)
                    Markdown(content)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .lineLimit(nil)
                        .textSelection(.enabled)
                    
                }
                if postView.post.embedTitle != nil && postView.post.thumbnailUrl != nil {
                    // Article View
                    VStack {
                        AsyncImage(url: URL(string: postView.post.thumbnailUrl!),
                                   content: { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(4)
                            default:
                                Text("Failed to load image.")
                                    .italic()
                            }
                        })
                        .padding(.leading, 4)
                        .padding(.trailing, 4)
                        .padding(.top, 4)
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
                    .onTapGesture {
                        openURL(url!)
                    }
                }
                else if postView.post.url != nil && postView.post.embedTitle == nil {
                    // Image-only view.
                    if LinkHelper.isAnimatedLink(link: postView.post.url!) {
                        // GIF
                        AnimatedImage(link: postView.post.url!, imageHeight: $gifHeight)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
                    } else if LinkHelper.isImageLink(link: postView.post.url!) {
                        // Static Images
                        Spacer()
                        Text("")
                        AsyncImage(url: URL(string: postView.post.url!),
                                   content: { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                            case .failure(_):
                                // Can't load image? Fallback to link.
                                Link("Failed to load image: \(postView.post.url!)", destination: URL(string: postView.post.url!)!)
                            default:
                                Text("Failed to load the image.")
                                    .italic()
                            }
                        })
                    } else {
                        // Simple external link.
                        let url = URL(string: postView.post.url!)!
                        Link(url.absoluteString, destination: url)
                    }
                    Spacer()
                }
                Spacer(minLength: 6)
                LazyHStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("in")
                        CommunityAvatar(community: postView.community)
                        Text(self.postView.community.name)
                            .fontWeight(.semibold)
                    }
                    HStack(spacing: 4) {
                        Text("by")
                        PersonDisplay(person: postView.creator)
                    }
                    DateDisplayView(date: self.postView.post.published)
                }
                .frame (
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Spacer(minLength: 6)
                LazyHStack {
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
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .background(Color(.textBackgroundColor))
            .cornerRadius(4)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(GeometryReader { innerGeometry in
                Color.clear
                    .onChange(of: innerGeometry.size.height) { newHeight in
                        // HACK: When scrolling up, the scrolling is jittery,
                        // as the elements that we offloaded are loaded back in.
                        // To prevent it, we store the highest known sample heigt,
                        // *until* we reach 2nd sample.
                        //
                        // We stop at 2nd sample, because stuff like images is already loaded.
                        // For some reason, after that, occasionally the maximum registered height
                        // gets doubloed, or even trippled.
                        //
                        // If someone has a better solution, be my guest to fix it.
                        if newHeight > minimumHeight && heightSamples < PostUIView.maxHeightSamples {
                            minimumHeight = newHeight
                            heightSamples += 1
                        }
                    }
            })
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: self.minimumHeight,
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
        
        }
        .contextMenu {
            PostContextMenu(postView: self.postView)
        }
    }
    
    func likePost() {
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
    func showHeight() -> String {
        return "\(minimumHeight)"
    }
}

struct LargestHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
