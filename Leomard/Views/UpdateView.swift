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
    @State var downloadProgress: Float = 0.1
    @State var downloadStatus: String = ""
    
    @State var alertShown: Bool = false
    @State var alertMessage: String = ""
    
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
                    ProgressView("Downloading...", value: downloadProgress, total: 1)
                    Text(downloadStatus)
                }
                HStack {
                    Button("Download & Install", action: download)
                        .buttonStyle(.borderedProminent)
                    Button("Visit Release Page", action: openReleasesPage)
                        .buttonStyle(.borderedProminent)
                    Button("Skip this version", role: .cancel, action: skipVersion)
                    Button("Later", role: .cancel, action: closeWindow)
                }
                .disabled(isDownloading)
            }
            .padding()
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
            .frame(width: 500, height: 350)
            .alert("Update Error", isPresented: $alertShown, actions: {
                Button("OK") {}
            }, message: { Text(alertMessage) })
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
        
        // Get asset that is a DMG file.
        var url: URL? = nil
        for asset in release!.assets {
            if asset.browserDownloadUrl.hasSuffix(".dmg") {
                url = URL(string: asset.browserDownloadUrl)!
                break
            }
        }
        
        if url == nil {
            // TODO: Add Alert.
            isDownloading = false
            return
        }
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url!) { location, _, error in
            if let error = error {
                isDownloading = false
                print(error)
                
                self.alertMessage = "Failed to check for update."
                self.alertShown = true
                return
            }
            
            guard let location = location else {
                self.alertMessage = "No location for downloaded file."
                self.alertShown = true
                return
            }
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectoryURL.appendingPathComponent(url!.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: location, to: destinationURL)
                NSWorkspace.shared.open(destinationURL)
            } catch {
                print("Error moving file: \(error.localizedDescription)")
                self.alertMessage = "Failed to moev file: \(error.localizedDescription)"
                self.alertShown = true
                return
            }
            
            DispatchQueue.main.async {
                isDownloading = false
                // Close app
                NSApplication.shared.terminate(self)
            }
        }
        
        task.resume()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let received = task.countOfBytesReceived
            let expected = task.countOfBytesExpectedToReceive
            let progress = expected == 0 ? 0.01 : Float(received) / Float(expected)
            print("\(progress)%")
            downloadProgress = progress
            
            let receivedMBs = ((Float(received) * pow(10, -6)) * 10).rounded() / 10
            let expectedMBs = ((Float(expected) * pow(10, -6)) * 10).rounded() / 10
            
            self.downloadStatus = "\(receivedMBs) / \(expectedMBs) MB"
            
            if downloadProgress >= 1 {
                timer.invalidate()
                self.downloadStatus = "Done!"
            }
        }
        timer.fire()
    }
    
    func skipVersion() {
        UserPreferences.getInstance.skippedUpdateVersion = String(describing: release!.tagName)
        closeWindow()
    }
}
