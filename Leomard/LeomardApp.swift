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
    //@StateObject var userPreferences: UserPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 800)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Preferences", action: showPreferences)
                    .keyboardShortcut(",", modifiers: .command)
            }
        }
        Window("Preferences", id: "preferences") {
            PreferencesView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
    
    func showPreferences() {
        self.openWindow(id: "preferences")
    }
}
