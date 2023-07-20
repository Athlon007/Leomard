//
//  UpdateView.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct UpdateView: View {
    let release: Release?
    
    var body: some View {
        if release == nil {
            Text("Unable to get the release.")
        } else {
            VStack {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Version **\(String(describing: release!.tagName))** is available to download!")
                    .font(.system(size: 24))
                Text("Your version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                List {
                    let content = MarkdownContent(release!.body)
                    Markdown(content)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                HStack {
                    Button("Download Now", action: download)
                        .buttonStyle(.borderedProminent)
                    Button("Later", role: .cancel, action: closeWindow)
                }
            }
            .padding()
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
            .frame(width: 500, height: 350)
        }
    }
    
    func closeWindow() {
        NSApplication.shared.keyWindow?.close()
    }
    
    func download() {
        closeWindow()
    }
}
