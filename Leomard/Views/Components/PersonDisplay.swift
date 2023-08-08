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
    var defaultForegroundColor: Color = .primary
    
    @State var color: Color = .primary

    var body: some View {
        PersonAvatar(person: person)
        Text(getDisplayName())
            .PersonNameFormat(person: person, myself: myself, defaultForegroundColor: defaultForegroundColor)
            .help(getHelpText())
    }
    
    func getDisplayName() -> String {
        var output = UserPreferences.getInstance.preferDisplayNamePeoplePost ? person.displayName ?? person.name : person.name
        if person.botAccount {
            output += " 🤖"
        }
        return output
    }
    
    func getHelpText() -> String {
        if person.botAccount {
            return "This account belongs to a bot."
        }
        
        return ""
    }
}

extension Text {
    func PersonNameFormat(person: Person, myself: MyUserInfo?, defaultForegroundColor: Color = .primary) -> some View {
        var color: Color = defaultForegroundColor
        if person.admin {
            color = .red
        }
        
        if person.botAccount {
            color = .green
        }
        
        if person.actorId == myself?.localUserView.person.actorId {
            color = .blue
        }
        
        if person.name == "athlon" && person.actorId.starts(with: "https://lemm.ee/u/") {
            color = .purple
        }
        
        return self.fontWeight(.semibold)
            .foregroundColor(color)
            .strikethrough(person.banned)
    }
}
