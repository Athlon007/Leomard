//
//  LeomardApp.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import SwiftUI

@main
struct LeomardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 800)
        }
            .windowStyle(HiddenTitleBarWindowStyle())
            .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
}
