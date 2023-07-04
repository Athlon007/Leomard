//
//  ProfileView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let sessionService: SessionService
    let contentView: ContentView
    
    var body: some View {
        Button("Logout", action: logout)
    }
    
    func logout() {
        sessionService.destroy()
        contentView.navigateToFeed()
        contentView.logout()
    }
}
