//
//  PostOpenedView.swift
//  Leomard
//
//  Created by Konrad Figura on 07/08/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import NukeUI

struct PostOpenedView: View {
    @State var postView: PostView
    let contentView: ContentView
    let commentService: CommentService
    let postService: PostService
    @Binding var myself: MyUserInfo?
    
    @State var comments: [CommentView] = []
    @State var page: Int = 1
    @State var lastPage: Bool = false
    @State var sortType: CommentSortType = UserPreferences.getInstance.commentSortMethod
    
    @State var commentText: String = ""
    @FocusState var isSendingComment: Bool
    
    @State var showingAlert: Bool = false
    
    var body: some View {
        PostUIView(postView: postView, shortBody: false, postService: self.postService, myself: $myself, contentView: contentView)
            .frame(
                minHeight: 0,
                alignment: .top
            )
            .task {
                self.loadComments()
            }
            .alert("Error", isPresented: $showingAlert, actions: {
                Button("Retry", role: .destructive) {
                    self.createComment()
                    showingAlert = false
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Failed to send a comment. Try again.")
            })
        Spacer()
        VStack {
            Text("Comment")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .fontWeight(.semibold)
            MarkdownEditor(bodyText: $commentText, contentView: self.contentView)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                    maxHeight: .infinity
                )
            Button("Send", action: createComment)
                .buttonStyle(.borderedProminent)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .disabled(isTextFieldEmpty())
            if isSendingComment {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(maxHeight: .infinity)
        Spacer()
        Picker("Sort By", selection: $sortType) {
            ForEach(CommentSortType.allCases, id: \.self) { method in
                Text(String(describing: method))
            }
        }
        .onChange(of: sortType) { value in
            page = 1
            self.comments = []
            loadComments()
        }
        .frame(maxWidth: 150)
        Spacer()
        ForEach(comments, id: \.self) { commentView in
            CommentUIView(commentView: commentView, indentLevel: 0, commentService: commentService, myself: $myself, post: postView.post, contentView: contentView)
                .onAppear {
                    if commentView == self.comments.last {
                        loadComments()
                    }
                }
            if !(commentView == self.comments.last && lastPage) {
                Divider()
            }
            Spacer()
        }
    }
    
    func loadComments() {
        self.commentService.getAllComments(post: postView.post, page: page, sortType: sortType) { result in
            switch result {
            case .success(let getCommentView) :
                self.comments += getCommentView.comments.filter { !self.comments.contains($0) }
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func createComment() {
        let comment = commentText
        
        if isSendingComment {
            return
        }
        
        isSendingComment = true
        
        commentService.createComment(content: comment, post: postView.post) { result in
            switch result {
            case .success(let commentResponse):
                DispatchQueue.main.sync {
                    comments.insert(commentResponse.commentView, at: 0)
                    commentText = ""
                    isSendingComment = false
                }
            case .failure(let error):
                print(error)
                showingAlert = true
            }
        }
    }
    
    func isTextFieldEmpty() -> Bool {
        return commentText.count == 0
    }
}

