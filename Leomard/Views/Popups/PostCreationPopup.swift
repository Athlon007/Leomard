//
//  PostCreationPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import NukeUI

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
    @State var isSendingPost: Bool = false
    
    @State var imageUploadFail: Bool = false
    @State var imageUploadFailReason: String = ""
    
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
                        VStack(alignment: .leading) {
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
                            Button("Add Image", action: addImage)
                            if LinkHelper.isImageLink(link: url) {
                                LazyImage(url: .init(string: url)) { state in
                                    if let image = state.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
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
                        HStack(spacing: 20) {
                            Button("Send", action: sendPost)
                                .buttonStyle(.borderedProminent)
                                .frame(
                                    alignment: .leading
                                )
                                .disabled(!canSendPost())
                            if isSendingPost {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Spacer()
                        }.frame(alignment: .leading)
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
        .alert("Error", isPresented: $isAlertShown, actions: {
            Button("Retry", role: .destructive) {
                sendPost()
                isAlertShown = false
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text(alertMessage)
        })
        .alert("Image Upload Failed", isPresented: $imageUploadFail, actions: {
            Button("OK") {}
        }, message: {
            Text(imageUploadFailReason)
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
        
        isSendingPost = true
        
        if self.editedPost != nil {
            self.postService.editPost(post: editedPost!.post, name: title, body: bodyText, url: url, nsfw: isNsfw) { result in
                switch result {
                case .success(let response):
                    self.onPostAdded(response.postView)
                    cleanWindow()
                    isSendingPost = false
                    contentView.closePostEdit()
                case .failure(let error):
                    print(error)
                    alertMessage = "Unable to edit post. Try again later."
                    isAlertShown = true
                    isSendingPost = false
                }
            }
        } else {
            self.postService.createPost(community: community, name: title, body: bodyText, url: url, nsfw: isNsfw) { result in
                switch result {
                case .success(let response):
                    self.onPostAdded(response.postView)
                    cleanWindow()
                    isSendingPost = false
                    contentView.closePostCreation()
                case .failure(let error):
                    print(error)
                    alertMessage = "Unable to send post. Try again later."
                    isAlertShown = true
                    isSendingPost = false
                }
            }
        }
    }
    
    func cleanWindow() {
        title = ""
        bodyText = ""
        url = ""
        isNsfw = false
    }
    
    func canSendPost() -> Bool {
        return title.count > 0 && self.isUrlValid && !isSendingPost
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
    
    func addImage() {
        let panel = NSOpenPanel()
        panel.prompt = "Select file"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .init(importedAs: "leomard.supported.image.types.jpg"),
            .init(importedAs: "leomard.supported.image.types.jpeg"),
            .init(importedAs: "leomard.supported.image.types.png"),
            .init(importedAs: "leomard.supported.image.types.webp"),
            .init(importedAs: "leomard.supported.image.types.gif")
        ]
        panel.begin { (result) -> Void in
            self.contentView.toggleInteraction(true)
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue, let url = panel.url {                
                let imageService = ImageService(requestHandler: RequestHandler())
                imageService.uploadImage(url: url) { result in
                    switch result {
                    case .success(let imageUploadResponse):
                        if self.url == "" {
                            // URL not set? Set the image as URL.
                            self.url = imageUploadResponse.data.link
                        } else {
                            // Otherwise add it to content of the bodyText.
                            if bodyText.count > 0 {
                                // If there already is some text, add new line.
                                bodyText += "\n\n"
                            }
                            
                            bodyText += "![](\(imageUploadResponse.data.link))\n\n"
                            
                        }
                    case .failure(let error):
                        if error is LeomardExceptions, let failReason = (error as! LeomardExceptions).tryGetErrorMessage() {
                            self.imageUploadFailReason = failReason
                        } else {
                            self.imageUploadFailReason = "Unable to upload the image :("
                        }
                        
                        self.imageUploadFail = true
                    }
                }
            }
        }
        panel.orderFrontRegardless()
        self.contentView.toggleInteraction(false)
    }
}
