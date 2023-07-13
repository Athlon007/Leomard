//
//  CommunityContextMenu.swift
//  Leomard
//
//  Created by Konrad Figura on 11/07/2023.
//

import Foundation
import SwiftUI

struct CommunityContextMenu: View {
    let communityView: CommunityView
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: {
            let url = URL(string: communityView.community.actorId)
            openURL(url!)
        }) {
            Text("Open Community in Browser")
                .padding()
        }
        Button(action: {
            Clipboard.copyToClipboard(text: communityView.community.actorId)
        }) {
            Text("Copy Community Link")
                .padding()
        }
        Divider()
        Button(action: {
            
        }) {
            Text("Block Community")
                .padding()
        }
        .disabled(true)
    }
}
