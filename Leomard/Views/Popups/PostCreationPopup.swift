//
//  PostCreationPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct PostCreationPopup: View {
    let contentView: ContentView
    let community: Community
    let postService: PostService
    @Binding var myself: MyUserInfo?
    let onPostAdded: (PostView) -> Void
    let editedPost: PostView?
    let crossPost: PostView?
    
    @State var title: String = ""
    @State var bodyText: String = ""
    @State var url: String = ""
    @State var isNsfw: Bool = false
    
    @State var isUrlValid: Bool = true
    @State var isAlertShown: Bool = false
    @State var alertMessage: String = ""
    @State var isSendingPost: Bool = false
    
    @State var isUploadingImage: Bool = false
    
    // Cross-post stuff
    @State var searchCommunityText: String = ""
    @State var communities: [CommunityView] = []
    @State var selectedCrossCommunity: Community? = nil
    
    @State var showCloseDialog: Bool = false
    
    @State var showDraftsDialog: Bool = false
    
    @State var postDrafts: PostDrafts = .init()
    @State var drafts: [PostDraft] = []
    
    @State var stopAutosave: Bool = false
    @State var restoredAutosave: PostDraft? = nil
    @State var showAutosaveFoundAlert: Bool = false
    
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
                    preClose()
                }
            VStack {
                VStack {
                    HStack {
                        Button("Dismiss", action: {
                            preClose()
                        })
                            .buttonStyle(.link)
                        Spacer()
                        Button("Drafts", action: {
                            showDraftsDialog = true
                        })
                        .buttonStyle(.link)
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
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
                            Button("Add Image", action: {
                                isUploadingImage = true
                                self.contentView.addImage { result in
                                    isUploadingImage = false
                                    switch result {
                                    case .success(let response):
                                        if self.url == "" {
                                            // URL not set? Set the image as URL.
                                            self.url = response.data.link
                                        } else {
                                            // Otherwise add it to content of the bodyText.
                                            if bodyText.count > 0 {
                                                // If there already is some text, add new line.
                                                bodyText += "\n\n"
                                            }
                                            
                                            bodyText += "![](\(response.data.link))\n\n"
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            })
                            if isUploadingImage {
                                ProgressView().progressViewStyle(.circular)
                            }
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
                        MarkdownEditor(bodyText: $bodyText, contentView: contentView)
                        Spacer()
                        Toggle("NSFW", isOn: $isNsfw)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        if crossPost != nil {
                            VStack {
                                Text("Community")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                TextField("Search Community", text: $searchCommunityText)
                                    .onSubmit {
                                        searchCommunity()
                                    }
                                List(communities, id: \.self) { community in
                                    HStack {
                                        CommunityAvatar(community: community.community)
                                        Text(community.community.name)
                                            .foregroundColor(selectedCrossCommunity == community.community ? .blue : .primary)
                                    }
                                    .onTapGesture {
                                        self.selectedCrossCommunity = community.community
                                    }
                                    Divider()
                                }
                                .frame(maxWidth: .infinity, minHeight: 20)
                                .listStyle(.bordered)
                                .cornerRadius(4)
                            }
                            .frame(maxWidth: .infinity)
                        }
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
                    .allowsHitTesting(!showDraftsDialog)
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
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
            }
            .cornerRadius(8)
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
        .alert("Save Post As Draft?", isPresented: $showCloseDialog, actions: {
            Button("Yes") {
                saveDraft()
                close()
            }
            Button("No") {
                close()
            }
            Button("Cancel", role: .cancel) {}
        })
        .overlay {
            draftsOverlay
        }
        .task {
            if self.editedPost != nil {
                self.title = self.editedPost!.post.name
                self.bodyText = self.editedPost!.post.body ?? ""
                self.url = self.editedPost!.post.url ?? ""
                self.isNsfw = self.editedPost!.post.nsfw
            } else if let post = self.crossPost {
                self.title = post.post.name
                self.url = post.post.url ?? ""
                self.isNsfw = post.post.nsfw
                
                self.bodyText += "cross-posted from: \(post.post.apId)\n\n"
                if let body = post.post.body {
                    for line in body.components(separatedBy: "\n") {
                        self.bodyText += ">\(line)\n"
                    }
                }
            }
            
            self.restoredAutosave = postDrafts.loadAutosave()
            if self.restoredAutosave != nil {
                showAutosaveFoundAlert = true
            } else {
                self.autosave()
            }
        }
        .alert("Autosave File Found", isPresented: $showAutosaveFoundAlert, actions: {
            Button("Restore") {
                self.title = restoredAutosave!.title
                self.bodyText = restoredAutosave!.body
                self.url = restoredAutosave!.url
                self.isNsfw = restoredAutosave!.nsfw
                
                autosave()
            }
            Button("Continue", role: .cancel) {
                autosave()
            }
        }, message: {
            Text("An autosave file has been found. Would you like to restore it?")
        })
    }
    
    @ViewBuilder
    private var draftsOverlay: some View {
        if showDraftsDialog {
            ZStack {
                Color(white: 0, opacity: 0.33)
                    .onTapGesture {
                        showDraftsDialog = false
                    }
                    .ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button("Dismiss", action: { showDraftsDialog = false })
                                .buttonStyle(.link)
                            Spacer()
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        Spacer()
                        if self.drafts.count == 0 {
                            Text("No drafts found.")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        List(self.drafts, id: \.self) { draft in
                            HStack {
                                VStack {
                                    if draft.title.count > 0 {
                                        Text(draft.title)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 24))
                                    }
                                    if draft.url.count > 0 {
                                        Text(draft.url)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                    if draft.body.count > 0 {
                                        Text(draft.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                Button(action: {
                                    self.title = draft.title
                                    self.bodyText = draft.body
                                    self.url = draft.url
                                    self.isNsfw = draft.nsfw
                                    
                                    showDraftsDialog = false
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .help("Use draft")
                                .buttonStyle(.link)
                                Button(action: {
                                    self.postDrafts.deleteDraft(draft: draft)
                                    self.drafts = postDrafts.loadDrafts()
                                }) {
                                    Image(systemName: "trash")
                                }
                                .help("Delete draft")
                                .foregroundColor(.red)
                                .buttonStyle(.link)
                            }
                            .frame(maxWidth: .infinity)
                            Divider()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .textFieldStyle(.roundedBorder)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .frame(maxWidth: 600, maxHeight: 600)
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
                .cornerRadius(8)
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
            }
            .task {
                self.drafts = postDrafts.loadDrafts()
            }
        }
    }
    
    func preClose() {
        if url.count > 0 || title.count > 0 || bodyText.count > 0 {
            showCloseDialog = true
        } else {
            close()
        }
    }
    
    func close() {
        stopAutosave = true
        postDrafts.removeAutosave()
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
            let sendToCommuntiy = crossPost != nil ? selectedCrossCommunity! : self.community
            self.postService.createPost(community: sendToCommuntiy, name: title, body: bodyText, url: url, nsfw: isNsfw) { result in
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
        if crossPost != nil && selectedCrossCommunity == nil {
            return false
        }
        
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
   
    func searchCommunity() {
        let searchService = SearchService(requestHandler: RequestHandler())
        searchService.search(query: searchCommunityText, searchType: .communities, page: 1) { result in
            switch result {
            case .success(let searchResponse):
                self.communities = searchResponse.communities
            case .failure(let error):
                print(error)
                // TODO: Show error.
            }
        }
    }
    
    func saveDraft() {
        let post = PostDraft(title: self.title, body: self.bodyText, url: self.url, nsfw: self.isNsfw)
        self.postDrafts.saveDraft(postDraft: post)
    }
    
    func autosave() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if stopAutosave {
                return
            }
            
            postDrafts.saveAutosave(postDraft: .init(title: self.title, body: self.bodyText, url: self.url, nsfw: isNsfw))
            autosave()
        }
    }
}
