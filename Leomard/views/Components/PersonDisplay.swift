//
//  PersonDisplay.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

struct PersonDisplay: View {
    let person: Person
    @Binding var myself: MyUserInfo?
    
    @State var color: Color = .primary

    var body: some View {
        PersonAvatar(person: person)
        Text(person.name)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .strikethrough(person.banned)
            .task {
                
                if person.admin {
                    self.color = .red
                }
                
                if person.botAccount {
                    self.color = .green
                }
                
                if person.actorId == myself?.localUserView.person.actorId {
                    self.color = .blue
                }
                
                if person.name == "athlon" && person.actorId.starts(with: "https://lemm.ee/u/") {
                    self.color = .purple
                }
            }
    }
}
