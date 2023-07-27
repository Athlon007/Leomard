//
//  CommentContextMenu.swift
//  Leomard
//
//  Created by Konrad Figura on 11/07/2023.
//

import Foundation
import SwiftUI

struct CommentContextMenu: View {
    let contentView: ContentView
    let commentView: CommentView
    let onDistinguish: () -> Void
    let onRemove: () -> Void
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: {
            let url = URL(string: commentView.comment.apId)
            openURL(url!)
        }) {
            Text("Open Comment in Browser")
                .padding()
        }
        Button(action: {
            Clipboard.copyToClipboard(text: commentView.comment.apId)
        }) {
            Text("Copy Comment Link")
                .padding()
        }
        Divider()
        if commentView.creator != contentView.myUser?.localUserView.person {
            Button(action: {
                contentView.startReport(commentView.comment)
            }) {
                Text("Report")
                    .padding()
            }
        }
        if contentView.myUser != nil && contentView.myUser!.mods(community: commentView.community) {
            Divider()
            Menu("Mod Tools") {
                Button(commentView.comment.distinguished ? "Undistinguish" : "Distinguish") {
                    onDistinguish()
                }
                Button("Remove") {
                    onRemove()
                }
            }
        }
    }
}

