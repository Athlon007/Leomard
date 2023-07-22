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
        Button(action: {
            contentView.startReport(commentView.comment)
        }) {
            Text("Report")
                .padding()
        }
        Button(action: {
            
        }) {
            Text("Block User")
                .padding()
        }
        .disabled(true)
    }
}

