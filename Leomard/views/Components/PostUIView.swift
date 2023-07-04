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
    private static let maxPostLength: Int = 400
    
    @State var postBody: String? = nil
    @State var url: URL? = nil
    @State var gifHeight: CGFloat = 400
    
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
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: 20,
                                    alignment: .leading
                                )
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
            else if postView.post.url != nil {
                // Image-only view.
                if LinkHelper.isAnimatedLink(link: postView.post.url!) {                    
                    AnimatedImage(link: postView.post.url!, imageHeight: $gifHeight)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: gifHeight, maxHeight: .infinity, alignment: .leading)
                } else {
                    let content = MarkdownContent("![](" + postView.post.url! + ")")
                    Markdown(content)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .lineLimit(nil)
                }
                Spacer()
            }
            Spacer(minLength: 6)
            LazyHStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("in")
                        .fontWeight(.semibold)
                    Text(self.postView.community.name)
                }
                HStack(spacing: 4) {
                    Text("by")
                        .fontWeight(.semibold)
                    Text(self.postView.creator.name)
                }
                let elapsed = DateFormatConverter.getElapsedTime(from: self.postView.post.published)
                if elapsed.days == 0 && elapsed.hours == 0 && elapsed.minutes == 0 {
                    Text("(\(elapsed.seconds) seconds ago)")
                } else if elapsed.days == 0 && elapsed.hours == 0 {
                    Text("(\(elapsed.minutes) minutes ago)")
                } else if elapsed.days == 0 {
                    Text("(\(elapsed.hours) hours ago)")
                } else {
                    Text("(\(elapsed.days) days ago)")
                }
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
                HStack {
                    Image(systemName: "arrow.down")
                    Text(String(postView.counts.downvotes))
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
            maxHeight: .infinity
        )
        .task {
            self.postBody = self.postView.post.body
            if self.postBody != nil {
                self.postBody = postBody!.replacingOccurrences(of: "\r", with: "<br>")
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
}
