//
//  CommentUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct CommentUIView: View {
    @State var commentView: CommentView
    let indentLevel: Int
    let commentService: CommentService
    @Binding var myself: MyUserInfo?
    @State var post: Post
    
    
    static let intentOffset: Int = 15
    static let limit: Int = 10
    
    @State var subComments: [CommentView] = []
    @State var page: Int = 1
    @State var lastResultEmpty: Bool = false
    @State var hidden: Bool = false
    
    @State var isReplying: Bool = false
    @State var commentText: String = ""
    @FocusState var isSendingComment: Bool
    @State var isEditingComment: Bool = false
    
    var body: some View {
        if commentView.comment.deleted {
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
        } else if commentView.comment.removed {
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
                        PersonDisplay(person: commentView.creator, myself: $myself)
                        HStack {
                            Image(systemName: "arrow.up")
                            Text(String(commentView.counts.upvotes))
                        }
                        .foregroundColor(commentView.myVote != nil && commentView.myVote! > 0 ? .orange : .primary)
                        .onTapGesture {
                            likeComment()
                        }
                        HStack {
                            Image(systemName: "arrow.down")
                            Text(String(commentView.counts.downvotes))
                        }
                        .foregroundColor(commentView.myVote != nil && commentView.myVote! < 0 ? .blue : .primary)
                        .onTapGesture {
                            dislikeComment()
                        }
                        if commentView.counts.childCount > 0 {
                            HStack {
                                Image(systemName: "ellipsis.message")
                                Text(String(commentView.counts.childCount))
                            }
                        }
                        DateDisplayView(date: self.commentView.comment.published)
                        if commentView.comment.updated != nil {
                            HStack {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    HStack {
                        if commentView.creator.actorId == myself?.localUserView.person.actorId {
                            Button(action: startEditComment) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.link)
                            .foregroundColor(.primary)
                            Button(action: deleteComment) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.link)
                            .foregroundColor(.primary)
                        }
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
                if self.hidden {
                    Button("...", action: showComment)
                        .buttonStyle(.plain)
                        .foregroundColor(Color(.secondaryLabelColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    let content = MarkdownContent(commentView.comment.content)
                    Markdown(content)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .onTapGesture {
                            hideComment()
                        }
                    if isReplying || isEditingComment {
                        Spacer()
                        VStack {
                            Text(isEditingComment ? "Edit" :"Reply")
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
                                Button(isEditingComment ? "Save" : "Send", action: onSaveSendCommentClick)
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
                    if subComments.count > 0 {
                        Spacer()
                        ForEach(subComments, id: \.self) { commentView in
                            CommentUIView(commentView: commentView, indentLevel: self.indentLevel + 1, commentService: commentService, myself: $myself, post: post)
                            if commentView != self.subComments.last {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                        if !lastResultEmpty {
                            Divider()
                            Button("Load more...", action: loadSubcomments)
                                .buttonStyle(.plain)
                                .foregroundColor(Color(.secondaryLabelColor))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, CGFloat(CommentUIView.intentOffset))
                        }
                    }
                }
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.leading, CGFloat(CommentUIView.intentOffset * self.indentLevel))
            .task {
                if self.indentLevel == 0 && self.commentView.counts.childCount > 0 {
                    loadSubcomments()
                }
            }
        }
    }
    
    func loadSubcomments() {
        self.commentService.getSubcomments(comment: self.commentView.comment, page: page, level: self.indentLevel + 1) { result in
            switch result {
            case .success(let getCommentView):
                self.subComments = self.subComments + getCommentView.comments
                page += 1
                if getCommentView.comments.count == 0 || getCommentView.comments.count < CommentUIView.limit {
                    self.lastResultEmpty = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func hideComment() {
        self.hidden = true
    }
    
    func showComment() {
        self.hidden = false
    }
    
    func likeComment() {
        var score = 1
        if commentView.myVote == 1 {
            score = 0
        }
        self.commentService.setCommentLike(comment: commentView.comment, score: score) { result in
            switch result {
            case .success(let commentResponse):
                self.commentView = commentResponse.commentView
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func dislikeComment() {
        var score = -1
        if commentView.myVote == -1 {
            score = 0
        }
        self.commentService.setCommentLike(comment: commentView.comment, score: score) { result in
            switch result {
            case .success(let commentResponse):
                self.commentView = commentResponse.commentView
            case .failure(let error):
                print(error)
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
        
        if isEditingComment {
            commentService.updateComment(comment: commentView.comment, content: comment) { result in
                switch result {
                case .success(let commentResponse):
                    DispatchQueue.main.sync {
                        commentView = commentResponse.commentView
                        subComments.insert(commentResponse.commentView, at: 0)
                        commentText = ""
                        isSendingComment = false
                        isEditingComment = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            commentService.createComment(content: comment, post: post, parent: commentView.comment) { result in
                switch result {
                case .success(let commentResponse):
                    DispatchQueue.main.sync {
                        subComments.insert(commentResponse.commentView, at: 0)
                        commentText = ""
                        isSendingComment = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func isSendable() -> Bool {
        return commentText.count > 0 && !isSendingComment
    }
    
    func cancelComment() {
        commentText = ""
        isReplying = false
        isEditingComment = false
    }
    
    func deleteComment() {
        commentService.deleteComment(comment: commentView.comment) { result in
            switch result {
            case .success(_):
                self.commentView.comment.deleted = true
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startEditComment() {
        isEditingComment = true
        commentText = commentView.comment.content
    }
    
}
