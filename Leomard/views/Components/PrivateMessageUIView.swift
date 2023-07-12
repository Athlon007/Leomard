//
//  PrivateMessageUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct PrivateMessageUIView: View {
    @State var privateMessageView: PrivateMessageView
    let privateMessageService: PrivateMessageService
    @Binding var myself: MyUserInfo?
    let contentView: ContentView
    @Binding var unreadOnlyMode: Bool
    
    @State var isReplying: Bool = false
    @State var commentText: String = ""
    @FocusState var isSendingComment: Bool
    @State var updatedTimeAsString: String = ""
    @State var isReplied: Bool = false
    
    var body: some View {
        if isReplied {
            EmptyView()
        } else {
            VStack {
                if privateMessageView.privateMessage.deleted {
                    VStack {
                        Text("Message deleted by the user.")
                            .italic()
                            .foregroundColor(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        Divider()
                    }
                } else {
                    VStack {
                        HStack {
                            HStack {
                                PersonDisplay(person: privateMessageView.creator, myself: $myself)
                                    .onTapGesture {
                                        contentView.openPerson(profile: privateMessageView.creator)
                                    }
                                Text("to")
                                PersonDisplay(person: privateMessageView.recipient, myself: $myself)
                                    .onTapGesture {
                                        contentView.openPerson(profile: privateMessageView.recipient)
                                        
                                    }
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            HStack {
                                Button(action: toggleMarkAsRead) {
                                    Image(systemName: "envelope.open")
                                }
                                .buttonStyle(.link)
                                .foregroundColor(privateMessageView.privateMessage.read ? .blue : .primary)
                                Button(action: startReply) {
                                    Image(systemName: "arrowshape.turn.up.left")
                                }
                                .buttonStyle(.link)
                                .foregroundColor(.primary)
                            }
                            .frame(
                                minWidth: 0,
                                alignment: .trailing
                            )
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        
                        let content = MarkdownContent(privateMessageView.privateMessage.content)
                        Markdown(content)
                            .lineLimit(nil)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        if isReplying {
                            Spacer()
                            VStack {
                                Text("Reply")
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .fontWeight(.semibold)
                                TextEditor(text: $commentText)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 0.5))
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                                        maxHeight: .infinity,
                                        alignment: .leading
                                    )
                                    .lineLimit(5...)
                                    .font(.system(size: NSFont.preferredFont(forTextStyle: .body).pointSize))
                                HStack {
                                    Button("Send", action: onSaveSendCommentClick)
                                        .buttonStyle(.borderedProminent)
                                        .frame(
                                            alignment: .leading
                                        )
                                        .disabled(!isSendable())
                                    Button("Cancel", action: cancelComment)
                                        .buttonStyle(.automatic)
                                        .frame(
                                            alignment: .leading
                                        )
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                        }
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .contextMenu {
                        //CommentContextMenu(commentView: self.commentView)
                    }
                    .padding()
                }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(4)
        }
    }
    
    func startReply() {
        isReplying = true
    }
    
    func onSaveSendCommentClick() {
        if !isSendable() {
            return
        }
        
        isSendingComment = true
        let comment = commentText
        
        privateMessageService.sendPrivateMessage(content: comment, recipient: privateMessageView.creator) { result in
            switch result {
            case .success(let privateMessageResponse):
                DispatchQueue.main.sync {
                    commentText = ""
                    isSendingComment = false
                    isReplied = true
                    
                    // Mark it too as read.
                    privateMessageService.markAsRead(privateMessage: privateMessageResponse.privateMessageView.privateMessage, read: true) {_ in }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func isSendable() -> Bool {
        return commentText.count > 0 && !isSendingComment
    }
    
    func cancelComment() {
        commentText = ""
        isReplying = false
    }
    
    func toggleMarkAsRead() {
        self.privateMessageService.markAsRead(privateMessage: self.privateMessageView.privateMessage, read: !self.privateMessageView.privateMessage.read) { result in
            switch result {
            case .success(let response):
                if unreadOnlyMode {
                    self.isReplied = true
                }
                self.privateMessageView.privateMessage.read = response.privateMessageView.privateMessage.read
                self.contentView.updateUnreadMessagesCount()
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
