//
//  PostContextMenu.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

struct PostContextMenu: View {
    let contentView: ContentView
    let postView: PostView
    let sender: PostUIView
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
            Clipboard.copyToClipboard(text: postView.post.apId)
        }) {
            Text("Copy Post Link")
                .padding()
        }
        if let url = postView.post.url {
            Button(action: {
                openURL(URL(string: url)!)
            }) {
                Text("Open External Link")
                    .padding()
            }
            Button(action: {
                Clipboard.copyToClipboard(text: url)
            }) {
                Text(LinkHelper.isImageLink(link: url) ? "Copy Image Link" : "Copy External Link")
                    .padding()
            }
            if LinkHelper.isImageLink(link: url) {
                Button(action: {
                    Clipboard.copyImageToClipboard(imageLink: url)
                }) {
                    Text("Copy Image")
                        .padding()
                }
                Button(action: {
                    saveImage(imageLink: url)
                }) {
                    Text("Save Image to Downloads")
                        .padding()
                }
            }
        }
        Divider()
        Button(action: {
            sender.markAsRead(!postView.read)
        }) {
            Text(postView.read ? "Mark as unread" : "Mark as read")
        }
        Divider()
        ShareLink(item: URL(string: postView.post .apId)!) {
            Text("Share")
        }
        if postView.creator != contentView.myUser?.localUserView.person {
            Button(action: {
                contentView.startReport(postView.post)
            }) {
                Text("Report")
                    .padding()
            }
        }
        if contentView.myUser != nil && contentView.myUser!.mods(community: postView.community) {
            Divider()
            Menu("Mod Tools") {
                Button(postView.post.featuredCommunity ? "Unpin" : "Pin") {
                    sender.featureCommunity()
                }
                Button(postView.post.locked ? "Unlock" : "Lock") {
                    sender.lock()
                }
                Button("Remove") {
                    sender.startPostRemoval()
                }
            }
        }
    }
    
    func saveImage(imageLink: String) {
        let url = URL(string: imageLink)!
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            let fileName = url.lastPathComponent
            guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                return
            }
            let fileURL = downloadsDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Image saved successfully!")
                
                if FileManager.default.fileExists(atPath: fileURL.path()) {
                    NSWorkspace.shared.open(fileURL)
                }
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        }.resume()
    }
}
