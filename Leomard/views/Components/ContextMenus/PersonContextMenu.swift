//
//  ProfileContextMenu.swift
//  Leomard
//
//  Created by Konrad Figura on 11/07/2023.
//

import Foundation
import SwiftUI

struct PersonContextMenu: View {
    let personView: PersonView
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: {
            let url = URL(string: personView.person.actorId)
            openURL(url!)
        }) {
            Text("Open Profile in Browser")
                .padding()
        }
        Button(action: {
            Clipboard.copyToClipboard(text: personView.person.actorId)
        }) {
            Text("Copy Profile Link")
                .padding()
        }
        Button(action: {
            Clipboard.copyToClipboard(text: "@" + personView.person.name + "@" + LinkHelper.stripToHost(link: personView.person.actorId))
        }) {
            Text("Copy Handle")
                .padding()
        }
        Divider()
        Button(action: {
            
        }) {
            Text("Report")
                .padding()
        }
        .disabled(true)
        Button(action: {
            
        }) {
            Text("Block")
                .padding()
        }
        .disabled(true)
    }
}

