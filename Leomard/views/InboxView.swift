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
    let sessionService: SessionService
    @Binding var myself: MyUserInfo?
    let contentView: ContentView
    let commentService: CommentService
    
    @State var privateMessageService: PrivateMessageService? = nil
    
    let views: [Option] = [
        .init(id: 0, title: "Replies", imageName: "ellipsis.message"),
        .init(id: 1, title: "Private Messages", imageName: "mail")
    ]
    @State var selectedView: Option = .init(id: 0, title: "Replies", imageName: "ellipsis.message")
    
    @State var commentReplies: [CommentReplyView] = []
    @State var privateMessages: [PrivateMessageView] = []
    @State var page: Int = 1
    @State var unreadOnly: Bool = true
    @State var reachedEnd: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            HStack {
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
                Toggle("Unread Only", isOn: $unreadOnly)
                    .onChange(of: unreadOnly) { value in
                        self.page = 1
                        self.loadContent()
                    }
            }
            List {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                switch selectedView {
                case views[1]:
                    if privateMessages.count == 0 && !isLoading {
                        Text("You don't have any private messages.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(privateMessages, id: \.self) { privateMessage in
                        Text(privateMessage.privateMessage.content)
                    }
                default:
                    if commentReplies.count == 0 && !isLoading {
                        Text("You don't have any replies.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(commentReplies, id: \.self) { commentReply in
                        CommentReplyUIView(commentReplyView: commentReply, commentService: commentService, myself: $myself, contentView: contentView)
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
            .frame(maxWidth: 600, maxHeight: .infinity)
            if selectedView == views[1] {
                Spacer()
                Text("DISCLAIMER: Private messages in Lemmy are not secure.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            self.privateMessageService = PrivateMessageService(requestHandler: requestHandler, sessionService: sessionService)
            self.selectedView = views[0]
            
            self.loadContent()
        }
    }
    
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
                    self.privateMessages += privateMessagesResponse.privateMessages
                    
                    if privateMessagesResponse.privateMessages.count == 0 {
                        reachedEnd = true
                    }
                    
                case .failure(let error):
                    print(error)
                    self.isLoading = false
                }
            }
        default:
            self.repliesService.getReplies(unreadOnly: self.unreadOnly, sortType: .new, page: page) { result in
                switch result {
                case .success(let repliesResponse):
                    self.isLoading = false
                    self.commentReplies += repliesResponse.replies
                    
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
}
