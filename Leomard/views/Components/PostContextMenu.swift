//
//  PostContextMenu.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

struct PostContextMenu: View {
    let postView: PostView
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: {
            let url = URL(string: postView.post.apId)
            openURL(url!)
        }) {
            Text("Open Post in Browser")
                .padding()
        }
        Button(action: {
            copyToClipboard(text: postView.post.apId)
        }) {
            Text("Copy Post Link")
                .padding()
        }
        if postView.post.url != nil {
            Button(action: {
                copyToClipboard(text: postView.post.url!)
            }) {
                Text(LinkHelper.isImageLink(link: postView.post.url!) ? "Copy Image Link" : "Copy External Link")
                    .padding()
            }
            if LinkHelper.isImageLink(link: postView.post.url!) {
                Button(action: {
                    copyImageToClipboard(imageLink: postView.post.url!)
                }) {
                    Text("Copy Image")
                        .padding()
                }
            }
        }
        Divider()
        ShareLink(item: URL(string: postView.post .apId)!) {
            Text("Share...")
        }
    }
    
    func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: NSPasteboard.PasteboardType.string)
    }
    
    func copyImageToClipboard(imageLink: String) {
        guard let imageURL = URL(string: imageLink) else {
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: imageURL) { data, response, error in
            guard let data = data, let image = NSImage(data: data) else {
                return
            }
            
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([image] as [NSPasteboardWriting])
        }
        
        task.resume()
    }
    
    func sharePost() {

    }
}
