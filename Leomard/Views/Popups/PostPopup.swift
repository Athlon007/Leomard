//
//  PostPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation
import SwiftUI

struct PostPopup: View {
    let postView: PostView
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
                    List {
                        PostUIView(postView: postView, shortBody: false, postService: self.postService, myself: $myself, contentView: contentView)
                            .frame(
                                minHeight: 0,
                                alignment: .top
                            )
                        Spacer()
                        VStack {
                            Text("Comment")
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
                    .frame(
                        minHeight: 0,
                        maxHeight: .infinity
                    )
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
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
    }
    
    func close() {
        contentView.closePost()
        page = 1
    }
    
    func loadComments() {        
        self.commentService.getAllComments(post: postView.post, page: page, sortType: sortType) { result in
            switch result {
            case .success(let getCommentView) :
                self.comments += getCommentView.comments
                page += 1
                
                if getCommentView.comments == [] {
                    self.lastPage = true
                }
                
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
