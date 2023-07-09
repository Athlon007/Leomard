//
//  UserSearchUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

struct UserSearchUIView: View {
    @State var personView: PersonView
    let contentView: ContentView
    
    var body: some View {
        ZStack {
            /*
            if personView.person.banner != nil {
                AsyncImage(url: URL(string: personView.person.banner!)!, content: { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.1)
                            .frame(maxWidth: 600, maxHeight: .infinity)
                    default:
                        VStack {}
                    }
                })
                .padding(.trailing, -25)
            }*/
            HStack {
                PersonAvatar(person: personView.person, size: 100)
                VStack(spacing: 10) {
                    VStack {
                        Text(personView.person.displayName ?? personView.person.name)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 18))
                        Text(personView.person.name + "@" + LinkHelper.stripToHost(link: personView.person.actorId))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: 600, maxHeight: 100, alignment: .leading)
        .onTapGesture {
            contentView.openPerson(profile: personView.person)
        }
    }
}
