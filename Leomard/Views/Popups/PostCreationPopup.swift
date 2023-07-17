//
//  PostCreationPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct PostCreationPopup: View {
    let contentView: ContentView
    let community: Community
    let postService: PostService
    @Binding var myself: MyUserInfo?
    let onPostAdded: (PostView) -> Void
    let editedPost: PostView?
    
    @State var title: String = ""
    @State var bodyText: String = ""
    @State var url: String = ""
    @State var isNsfw: Bool = false
    
    @State var isUrlValid: Bool = true
    @State var isAlertShown: Bool = false
    @State var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            VStack {  }
                .frame (
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .background(Color.black)
                .opacity(0.33)
                .onTapGesture {
                    close()
                }
            VStack {
                VStack {
                    HStack {
                        Button("Dismiss", action: close)
                            .buttonStyle(.link)
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                    
                    VStack {
                        Text("Title")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .fontWeight(.semibold)
                        TextField("", text: $title)
                        Text("URL")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .fontWeight(.semibold)
                        TextField("", text: $url)
                            .onChange(of: url) { _ in
                                checkUrlValidity()
                            }
                            .border(!isUrlValid ? .red : .clear, width: 4)
                        Text("Body")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .fontWeight(.semibold)
                        Spacer()
                        VStack {
                            Spacer()
                            TextEditor(text: $bodyText)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 0.5))
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                                    maxHeight: .infinity,
                                    alignment: .leading
                                )
                                .lineLimit(5...)
                                .font(.system(size: NSFont.preferredFont(forTextStyle: .body).pointSize))
                            Text("Preview")
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .fontWeight(.semibold)
                            List {
                                let content = MarkdownContent(bodyText)
                                Markdown(content)
                                    .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    maxHeight: .infinity,
                                    alignment: .leading
                                )
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                        Spacer()
                        Toggle("NSFW", isOn: $isNsfw)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        Button("Send", action: sendPost)
                            .buttonStyle(.borderedProminent)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .disabled(!canSendPost())
                    }
                    .padding()
                }
                .frame(
                    minWidth: 0,
                    maxWidth: 600,
                    minHeight: 0,
                    maxHeight: 750
                )
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
            }
            .cornerRadius(4)
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
        .alert("Failed to send post", isPresented: $isAlertShown, actions: {
            Button("Retry", role: .destructive) {
                sendPost()
                isAlertShown = false
            }
        }, message: {
            Text("Unable to send post. Try again later.")
        })
        .task {
            if self.editedPost != nil {
                self.title = self.editedPost!.post.name
                self.bodyText = self.editedPost!.post.body ?? ""
                self.url = self.editedPost!.post.url ?? ""
                self.isNsfw = self.editedPost!.post.nsfw
            }
        }
    }
    
    func close() {
        contentView.closePostCreation()
    }
    
    func sendPost() {
        if !canSendPost() {
            return
        }
        
        if self.editedPost != nil {
            self.postService.editPost(post: editedPost!.post, name: title, body: bodyText, url: url, nsfw: isNsfw) { result in
                switch result {
                case .success(let response):
                    self.onPostAdded(response.postView)
                    contentView.closePostEdit()
                case .failure(let error):
                    print(error)
                    alertMessage = "Unable to edit post. Try again later."
                    isAlertShown = true
                }
            }
        } else {
            self.postService.createPost(community: community, name: title, body: bodyText, url: url, nsfw: isNsfw) { result in
                switch result {
                case .success(let response):
                    contentView.closePostCreation()
                    self.onPostAdded(response.postView)
                case .failure(let error):
                    print(error)
                    alertMessage = "Unable to send post. Try again later."
                    isAlertShown = true
                }
            }
        }
    }
    
    func canSendPost() -> Bool {
        return title.count > 0 && self.isUrlValid
    }
    
    func checkUrlValidity() {
        if url.count == 0 {
            self.isUrlValid = true
            return
        }
        
         let urlText = url
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if urlText != url {
                // We kinda don't wanna spam HEAD requests...
                return
            }
            
            let url = URL(string: url)
            if url == nil {
                self.isUrlValid = false
                return
            }
            
            url?.isReachable() { success in
                self.isUrlValid = success
            }
        }
    }
}
