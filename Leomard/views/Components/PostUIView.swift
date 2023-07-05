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

struct PostUIView: View {
    @State var postView: PostView
    let shortBody: Bool
    let postService: PostService
    @Binding var myself: MyUserInfo?
    
    private static let maxPostLength: Int = 400
    
    @State var postBody: String? = nil
    @State var url: URL? = nil
    
    @State var gifHeight: CGFloat = 400
    
    // Height retention variables
    @State var titleHeight: CGFloat = 0
    @State var bodyHeight: CGFloat = 0
    @State var imageHeight: CGFloat = 0

    @Environment(\.openURL) var openURL
    
    var body: some View {
        LazyVStack {
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
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                self.bodyHeight = geometry.size.height
                            }
                    })
                
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(4)
                                .background(GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            self.imageHeight = geometry.size.height
                                        }
                                })
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
                                .background(GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            self.imageHeight = geometry.size.height
                                        }
                                })
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
                    PersonDisplay(person: postView.creator, myself: $myself)
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
}
