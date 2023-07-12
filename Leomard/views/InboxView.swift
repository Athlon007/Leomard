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
                switch selectedView {
                case views[1]:
                    ForEach(privateMessages, id: \.self) { privateMessage in
                        Text(privateMessage.privateMessage.content)
                    }
                default:
                    ForEach(commentReplies, id: \.self) { commentReply in
                        Text(commentReply.comment.content)
                    }
                }
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
        }
        
        switch selectedView {
        case views[1]:
            self.privateMessageService!.getPrivateMessages(unreadOnly: self.unreadOnly, page: self.page) { result in
                switch result {
                case .success(let privateMessagesResponse):
                    self.privateMessages = privateMessagesResponse.privateMessages
                case .failure(let error):
                    print(error)
                }
            }
        default:
            self.repliesService.getReplies(unreadOnly: self.unreadOnly, sortType: .new, page: page) { result in
                switch result {
                case .success(let repliesResponse):
                    self.commentReplies = repliesResponse.replies
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
