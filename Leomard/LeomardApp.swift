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

    var body: some Scene {
        WindowGroup {
            ContentView(columnStatus: $mainWindowNavSplitStatus)
                .frame(minWidth: mainWindowNavSplitStatus == .detailOnly ? 600 : 800, minHeight: 800)
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
    }
    
    func showPreferences() {
        self.openWindow(id: "preferences")
    }
}
