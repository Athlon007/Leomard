//
//  LeomardApp.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import SwiftUI

@main
struct LeomardApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @State private var mainWindowNavSplitStatus = NavigationSplitViewVisibility.automatic
    
    @State private var latestRelease: Release? = nil

    var body: some Scene {
        WindowGroup {
            ContentView(columnStatus: $mainWindowNavSplitStatus)
                .frame(minWidth: mainWindowNavSplitStatus == .detailOnly ? 600 : 800, minHeight: 800)
                .task {
                    checkForUpdateOnStart()
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Preferences", action: showPreferences)
                    .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        Window("Preferences", id: "preferences") {
            PreferencesView()
                .frame(minWidth: 600, maxWidth: 600, maxHeight: 800)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .windowResizability(.contentSize)
        
        Window("Update Available", id: "update_window") {
            UpdateView(release: self.latestRelease)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .windowResizability(.contentSize)
    }
    
    func showPreferences() {
        self.openWindow(id: "preferences")
    }
    
    func checkForUpdateOnStart() {
        if !UserPreferences.getInstance.checkForUpdates {
            return
        }
        
        self.checkForUpdates()
    }
    
    func checkForUpdates() {
        let githubService = GithubService(requestHandler: RequestHandler())
        
        githubService.getLatestReleases { result in
            switch result {
            case .success(let release):
                if let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let localVersion = try? TagNameVersion(textVersion: appVersionString) {
                    if release.tagName > localVersion && String(describing: release.tagName) != UserPreferences.getInstance.skippedUpdateVersion {
                        print("Newer version available.")
                        self.latestRelease = release
                        DispatchQueue.main.sync {
                            self.openWindow(id: "update_window")
                        }
                    } else {
                        print("Up-to-date. Your version: \(String(describing: localVersion)). Newest: \(String(describing: release.tagName))")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
