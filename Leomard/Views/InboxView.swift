//
//  InboxView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation
import SwiftUI

struct InboxView: View {
    let repliesService: RepliesService
    let requestHandler: RequestHandler
    @Binding var myself: MyUserInfo?
    let contentView: ContentView
    let commentService: CommentService
    
    @State var privateMessageService: PrivateMessageService? = nil
    
    let views: [Option] = [
        .init(id: 0, title: "Replies", imageName: "ellipsis.message"),
        .init(id: 1, title: "Private Messages", imageName: "mail")
    ]
    @State var selectedView: Option = .init(id: 0, title: "Replies", imageName: "ellipsis.message")
    @State var selectedCommentSortType: CommentSortType = .new
    
    @State var commentReplies: [CommentReplyView] = []
    @State var privateMessages: [PrivateMessageView] = []
    @State var page: Int = 1
    @State var unreadOnly: Bool = UserPreferences.getInstance.unreadonlyWhenOpeningInbox
    @State var reachedEnd: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            toolbar
                .padding(.leading)
                .padding(.trailing)
            
            List {
                loadingIndicator(visible: isLoading)
                inboxContents(for: selectedView)
            }
            .frame(maxWidth: 600, maxHeight: .infinity)
            
            footerText
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            self.privateMessageService = PrivateMessageService(requestHandler: requestHandler)
            self.selectedView = views[0]
            
            self.loadContent()
        }
    }
    
    // MARK: - Toolbar
    
    @ViewBuilder
    private var toolbar: some View {
        HStack {
            Spacer()
            Image(systemName: selectedView.imageName)
                .padding(.trailing, 0)
            Picker("", selection: $selectedView) {
                ForEach(views, id: \.self) { method in
                    Text(String(describing: method.title))
                }
            }
            .frame(maxWidth: 160)
            .padding(.leading, -10)
            .onChange(of: selectedView) { value in
                self.page = 1
                self.loadContent()
            }
            if selectedView == views[0] {
                Image(systemName: selectedCommentSortType.image)
                    .padding(.trailing, 0)
                Picker("", selection: $selectedCommentSortType) {
                    ForEach(CommentSortType.allCases, id: \.self) { method in
                        Text(String(describing: method))
                    }
                }
                .frame(maxWidth: 80)
                .padding(.leading, -10)
                .onChange(of: selectedCommentSortType) { value in
                    self.page = 1
                    self.loadContent()
                }
            }
            Button(action: {
                self.page = 1
                self.loadContent()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            Toggle("Unread Only", isOn: $unreadOnly)
                .onChange(of: unreadOnly) { value in
                    self.page = 1
                    self.loadContent()
                }
            Spacer()
            if selectedView == views[0] {
                Button(action: markAllAsRead) {
                    Image(systemName: "envelope.open")
                }.buttonStyle(.link)
            }
        }
    }
    
    // MARK: -
    
    @ViewBuilder
    private func loadingIndicator(visible: Bool) -> some View {
        if visible {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    private func inboxContents(for selectedView: Option) -> some View {
        switch selectedView {
        case views[1]:
            privateMessagesView
        default:
            commentRepliesView
        }
    }
    
    @ViewBuilder
    private var privateMessagesView: some View {
        if privateMessages.count == 0 && !isLoading {
            Text("You don't have any private messages.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ForEach(privateMessages, id: \.self) { privateMessage in
                PrivateMessageUIView(privateMessageView: privateMessage, privateMessageService: privateMessageService!, myself: $myself, contentView: self.contentView, unreadOnlyMode: $unreadOnly)
                    .onAppear {
                        if privateMessage == privateMessages.last {
                            page += 1
                            loadContent()
                        }
                    }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var commentRepliesView: some View {
        if commentReplies.count == 0 && !isLoading {
            Text("You don't have any replies.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ForEach(commentReplies, id: \.self) { commentReply in
                CommentReplyUIView(commentReplyView: commentReply, commentService: commentService, myself: $myself, contentView: contentView, unreadOnlyMode: $unreadOnly)
                    .onAppear {
                        if commentReply == commentReplies.last {
                            page += 1
                            loadContent()
                        }
                    }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var footerText: some View {
        if selectedView == views[1] {
            Spacer()
            Text("DISCLAIMER: Private messages in Lemmy are not secure.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // MARK: -
    
    func loadContent() {
        if page == 1 {
            self.commentReplies = []
            self.privateMessages = []
            self.reachedEnd = false
        }
        
        if reachedEnd {
            return
        }
        
        self.isLoading = true
        
        switch selectedView {
        case views[1]:
            self.privateMessageService!.getPrivateMessages(unreadOnly: self.unreadOnly, page: self.page) { result in
                switch result {
                case .success(let privateMessagesResponse):
                    self.isLoading = false
                    self.privateMessages += privateMessagesResponse.privateMessages.filter { !self.privateMessages.contains($0) }
                    
                    if privateMessagesResponse.privateMessages.count == 0 {
                        reachedEnd = true
                    }
                    
                case .failure(let error):
                    print(error)
                    self.isLoading = false
                }
            }
        default:
            self.repliesService.getReplies(unreadOnly: self.unreadOnly, sortType: self.selectedCommentSortType, page: page) { result in
                switch result {
                case .success(let repliesResponse):
                    self.isLoading = false
                    self.commentReplies += repliesResponse.replies.filter { !self.commentReplies.contains($0) }
                    
                    if repliesResponse.replies.count == 0 {
                        reachedEnd = true
                    }
                    
                case .failure(let error):
                    print(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func markAllAsRead() {
        self.repliesService.markAllAsRead { result in
            switch result {
            case .success(_):
                if self.unreadOnly {
                    self.commentReplies = []
                } else {
                    self.page = 1
                    loadContent()
                }
                
                self.contentView.updateUnreadMessagesCount()
            case .failure(let error):
                print(error)
            }
        }
    }
}
