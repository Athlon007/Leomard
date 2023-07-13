//
//  AppAlertBadge.swift
//  Leomard
//
//  Created by Konrad Figura on 13/07/2023.
//

import Foundation
import SwiftUI
import AppKit

actor AppAlertBadge {
    @MainActor
    func setBadge(number: Int) {
        NSApplication.shared.dockTile.badgeLabel = String(number)
    }
    
    @MainActor
    func resetBadge() {
        NSApplication.shared.dockTile.badgeLabel = nil
    }
    
    @MainActor
    func setBadge(text: String) {
        NSApplication.shared.dockTile.badgeLabel = text
    }
}
