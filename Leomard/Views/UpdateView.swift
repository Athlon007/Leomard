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
    @Environment(\.openURL) var openURL
    
    @State var isDownloading: Bool = false
    @State var downloadProgress: Float = 0
    @State var downloadStatus: String = ""
    
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
                if isDownloading {
                    ProgressView("Downloading...", value: downloadProgress, total: 100)
                }
                HStack {
                    Button("Download & Update", action: download)
                        .buttonStyle(.borderedProminent)
                    Button("Visit Release Page", action: openReleasesPage)
                        .buttonStyle(.borderedProminent)
                    Button("Later", role: .cancel, action: closeWindow)
                }
                .disabled(isDownloading)
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
    
    func openReleasesPage() {
        self.openURL(URL(string: release!.htmlUrl)!)
        closeWindow()
    }
    
    func download() {
        isDownloading = true
                
        for asset in release!.assets {
            if asset.browserDownloadUrl.hasSuffix(".dmg") {
                break
            }
        }
    }
}
