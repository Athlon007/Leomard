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
import HighlightedTextEditor

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
    
    @State var imageUploadFail: Bool = false
    @State var imageUploadFailReason: String = ""
    @State var isUploadingImage: Bool = false
    
    // Cross-post stuff
    @State var searchCommunityText: String = ""
    @State var communities: [CommunityView] = []
    @State var selectedCrossCommunity: Community? = nil
    
    // Editing stuff
    @State var selectRange: NSRange = .init(location: 0, length: 0)
    let editorButtonsFont: Font = .custom(
            "AmericanTypewriter",
            fixedSize: NSFont.preferredFont(forTextStyle: .body).xHeight * 2)
    @State var adjustCursorBy: Int = 0
    @State var editorInsertionMode: EditorInsertionMode = .none
    @State var previousBodyLength: Int = 0
    @State var showInsertLink: Bool = false
    @State var insertLinkText: String = ""
    @State var insertLinkUrl: String = ""
    @State var insertImageToEditor: Bool = false
    
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
                        HStack {
                            Button(action: {
                                addToBody("**", on: .bothSides)
                            }, label: {
                                Image(systemName: "bold")
                            })
                            .help("Bold")
                            Button(action: {
                                addToBody("*", on: .bothSides)
                            }, label: {
                                Image(systemName: "italic")
                            })
                            .help("Italic")
                            Button(action: {
                                insertLinkText = ""
                                insertLinkUrl = ""
                                showInsertLink = true
                            }, label: {
                                Image(systemName: "link")
                            })
                            .help("Link")
                            Button(action: {
                                insertImageToEditor = true
                                addImage()
                            }, label: {
                                Image(systemName: "photo")
                            })
                            Button(action: {
                                addToBody("# ", on: .leftSide)
                            }, label: {
                                Text("H")
                                    .font(editorButtonsFont)
                            })
                            .help("Header")
                            Button(action: {
                                addToBody("~~", on: .bothSides)
                            }, label: {
                                Image(systemName: "strikethrough")
                            })
                            .help("Strikethrough")
                            Button(action: {
                                addToBody("> ", on: .leftSide)
                                editorInsertionMode = .quote
                            }, label: {
                                Image(systemName: "quote.closing")
                            })
                            .help("Quote")
                            Button(action: {
                                addToBody("- ", on: .leftSide)
                                editorInsertionMode = .bulletpoint
                            }, label: {
                                Image(systemName: "list.bullet")
                            })
                            .help("List")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(.link)
                        Spacer()
                        VStack {
                            Spacer()
                            HighlightedTextEditor(text: $bodyText, highlightRules: .markdown)
                                .onSelectionChange { (range: NSRange) in
                                    selectRange = range
                                    updateAutoInsertMode()
                                }
                                .introspect { editor in
                                    if adjustCursorBy != 0 {
                                        DispatchQueue.main.async {
                                            let range: NSRange = NSMakeRange(selectRange.location + adjustCursorBy, 0)
                                            editor.textView.setSelectedRange(range)
                                            adjustCursorBy = 0
                                        }
                                    }
                                    
                                }
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
        }
        .alert("Insert Link", isPresented: $showInsertLink, actions: {
            TextField("Text Displayed", text: $insertLinkText)
            TextField("URL", text: $insertLinkUrl)
            Button(action: {
                addToBody(" [\(insertLinkText)](\(insertLinkUrl))", on: .rightSide)
            }, label: { Text("Add") })
            Button(role: .cancel, action: {}, label: { Text("Cancel") })
        })
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
                isUploadingImage = true
                imageService.uploadImage(url: url) { result in
                    switch result {
                    case .success(let imageUploadResponse):
                        isUploadingImage = false
                        if self.url == "" && !insertImageToEditor {
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
                        insertImageToEditor = false
                    case .failure(let error):
                        isUploadingImage = false
                        if error is LeomardExceptions {
                            self.imageUploadFailReason = String(describing: error as! LeomardExceptions)
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
    
    // Makes sure that the lists and quotes are automatically inserted.
    func updateAutoInsertMode() {
        var removing = false
        let secondLast = selectRange.location > 0 ? bodyText[bodyText.index(bodyText.startIndex, offsetBy: selectRange.location - 1)] : Character("§")
        if previousBodyLength > bodyText.count && secondLast.isNewline {
            editorInsertionMode = .none
            removing = true
        }
        if !removing {
            if bodyText.last == "-" {
                editorInsertionMode = .bulletpoint
            } else if bodyText.last == ">" {
                editorInsertionMode = .quote
            }
        }
        
        if secondLast.isNewline {
            if editorInsertionMode == .bulletpoint {
                bodyText += "- "
                adjustCursorBy += 2
            } else if editorInsertionMode == .quote {
                bodyText += "> "
                adjustCursorBy += 2
            }
        }
        
        previousBodyLength = bodyText.count
    }
    
    func addToBody(_ set: String, on: AddOnSides) {
        var location = selectRange.location
        var length = selectRange.length
        if length == 0 {
            // If length is 0, adjust the location and length to select the entire word in bodyText.
            while location > 0 && !bodyText[bodyText.index(bodyText.startIndex, offsetBy: location - 1)].isWhitespace {
                location -= 1
            }
            
            while location + length < bodyText.count && !bodyText[bodyText.index(bodyText.startIndex, offsetBy: location + length)].isWhitespace {
                length += 1
            }
        }
        
        let startIndex = bodyText.index(bodyText.startIndex, offsetBy: location)
        let endIndex = bodyText.index(bodyText.startIndex, offsetBy: location + length)
        if on == .rightSide || on == .bothSides {
            self.bodyText.insert(contentsOf: set, at: endIndex)
        }
        if on == .leftSide || on == .bothSides {
            self.bodyText.insert(contentsOf: set, at: startIndex)
        }
        
        adjustCursorBy += on == .bothSides ? set.count : set.count
    }
}

enum AddOnSides {
    case leftSide
    case rightSide
    case bothSides
}

enum EditorInsertionMode {
    case none
    case bulletpoint
    case quote
}
