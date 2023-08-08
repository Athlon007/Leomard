//
//  PostPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 03/07/2023.
//

import Foundation
import SwiftUI
import HighlightedTextEditor

struct PostPopup: View {
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
                        PostOpenedView(postView: postView, contentView: contentView, commentService: commentService, postService: postService, myself: $myself)
                    }
                    .frame(
                        maxWidth: .infinity,
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
    }
    
    func close() {
        contentView.closePost()
        page = 1
    }    
}
