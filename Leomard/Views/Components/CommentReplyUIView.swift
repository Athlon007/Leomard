//
//  ComentReplyUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 12/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct CommentReplyUIView: View {
    @State var commentReplyView: CommentReplyView
    let commentService: CommentService
    @Binding var myself: MyUserInfo?
    let contentView: ContentView
    @Binding var unreadOnlyMode: Bool
    
    @State var isReplying: Bool = false
    @State var commentText: String = ""
    @FocusState var isSendingComment: Bool
    @State var updatedTimeAsString: String = ""
    @State var isReplied: Bool = false
    @State var sendingReplyFailed: Bool = false
    
    var body: some View {
        if isReplied && unreadOnlyMode {
            EmptyView()
        } else {
            VStack {
                if commentReplyView.comment.deleted {
                    VStack {
                        Text("Comment deleted by the user.")
                            .italic()
                            .foregroundColor(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        Divider()
                    }
                } else if commentReplyView.comment.removed {
                    VStack {
                        Text("Comment removed by moderator.")
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
                                PersonDisplay(person: commentReplyView.creator, myself: $myself)
                                    .onTapGesture {
                                        contentView.openPerson(profile: commentReplyView.creator)
                                        
                                    }
                                HStack {
                                    Image(systemName: "arrow.up")
                                    Text(String(commentReplyView.counts.upvotes))
                                }
                                .foregroundColor(commentReplyView.myVote != nil && commentReplyView.myVote! > 0 ? .orange : .primary)
                                .onTapGesture {
                                    likeComment()
                                }
                                HStack {
                                    Image(systemName: "arrow.down")
                                    Text(String(commentReplyView.counts.downvotes))
                                }
                                .foregroundColor(commentReplyView.myVote != nil && commentReplyView.myVote! < 0 ? .blue : .primary)
                                .onTapGesture {
                                    dislikeComment()
                                }
                                if commentReplyView.counts.childCount > 0 {
                                    HStack {
                                        Image(systemName: "ellipsis.message")
                                        Text(String(commentReplyView.counts.childCount))
                                    }
                                }
                                DateDisplayView(date: self.commentReplyView.comment.published)
                                if commentReplyView.comment.updated != nil {
                                    HStack {
                                        Image(systemName: "pencil")
                                        
                                    }.help(updatedTimeAsString)
                                }
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            if myself != nil {
                                HStack {
                                    Button(action: toggleMarkAsRead) {
                                        Image(systemName: "envelope.open")
                                    }
                                    .buttonStyle(.link)
                                    .foregroundColor(commentReplyView.commentReply.read ? .blue : .primary)
                                    Button(action: savePost) {
                                        Image(systemName: "bookmark")
                                    }
                                    .buttonStyle(.link)
                                    .foregroundColor(commentReplyView.saved ? .green : .primary)
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
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        
                        let content = MarkdownContent(commentReplyView.comment.content)
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
                                        .disabled(!isSendable())
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
                                    if isSendingComment {
                                        ProgressView().progressViewStyle(.circular)
                                    }
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
                    .task {
                        if commentReplyView.comment.updated != nil {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                            updatedTimeAsString = dateFormatter.string(from: commentReplyView.comment.updated!)
                        }
                    }
                    .contextMenu {
                        //CommentContextMenu(commentView: self.commentView)
                    }
                    .padding()
                }
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .onTapGesture {
                contentView.openPostForComment(comment: commentReplyView.comment)
            }
            .alert("Reply send fail", isPresented: $sendingReplyFailed, actions: {
                Button("Retry", role: .destructive) {
                    self.onSaveSendCommentClick()
                    sendingReplyFailed = false
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Unable to send a reply. Try again later.")
            })
        }
    }
    
    func likeComment() {
        if myself == nil {
            return
        }
        
        var score = 1
        if commentReplyView.myVote == 1 {
            score = 0
        }
        self.commentService.setCommentLike(comment: commentReplyView.comment, score: score) { result in
            switch result {
            case .success(let commentResponse):
                self.commentReplyView.comment = commentResponse.commentView.comment
                self.commentReplyView.myVote = commentResponse.commentView.myVote
                self.commentReplyView.counts = commentResponse.commentView.counts
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func dislikeComment() {
        if myself == nil {
            return
        }
        
        var score = -1
        if commentReplyView.myVote == -1 {
            score = 0
        }
        self.commentService.setCommentLike(comment: commentReplyView.comment, score: score) { result in
            switch result {
            case .success(let commentResponse):
                self.commentReplyView.comment = commentResponse.commentView.comment
                self.commentReplyView.myVote = commentResponse.commentView.myVote
                self.commentReplyView.counts = commentResponse.commentView.counts
            case .failure(let error):
                print(error)
                self.sendingReplyFailed = true
            }
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
        
        commentService.createComment(content: comment, post: commentReplyView.post, parent: commentReplyView.comment) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.sync {
                    commentText = ""
                    isSendingComment = false
                    isReplied = true
                    isReplying = false
                    
                    self.contentView.updateUnreadMessagesCount()
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
    
    func savePost() {
        let save = !commentReplyView.saved
        self.commentService.saveComment(comment: commentReplyView.comment, save: save) { result in
            switch result {
            case .success(let commentResponse):
                self.commentReplyView.saved = commentResponse.commentView.saved
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func toggleMarkAsRead() {
        self.contentView.repliesService?.markAsRead(commentReply: self.commentReplyView.commentReply, read: !self.commentReplyView.commentReply.read) { result in
            switch result {
            case .success(let response):
                if unreadOnlyMode {
                    self.isReplied = true
                }
                self.commentReplyView.commentReply.read = response.commentReplyView.commentReply.read
                self.contentView.updateUnreadMessagesCount()
            case .failure(let error):
                print(error)
            }
        }
    }
}
