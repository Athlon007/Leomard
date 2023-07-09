//
//  PreferenceView.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

struct PreferencesView: View {
    @StateObject var userPreferences: UserPreferences = UserPreferences()
    
    let preferenceOptions: [PreferenceOption] = [
        .init(name: "Content", icon: "text.alignleft", color: .blue),
        .init(name: "Experimental", icon: "testtube.2", color: .red)
    ]
    @State var currentSelection: PreferenceOption?

    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(preferenceOptions, id: \.self) { option in
                    HStack {
                        VStack {
                            Image(systemName: option.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: 14,
                                    height: 14
                                )
                                .foregroundColor(.white)
                                .padding(3)
                        }
                        .background(option.color)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(
                            width: 20, height: 20
                            )
                        Text(option.name)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .foregroundColor(currentSelection == option ? Color(.linkColor) : Color(.labelColor))
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    .onTapGesture {
                        self.currentSelection = option
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationBarBackButtonHidden(true)
        } detail: {
            List {
                switch currentSelection {
                case self.preferenceOptions[0]:
                    Picker("Default post sort method", selection: self.userPreferences.$postSortMethod) {
                        ForEach(self.userPreferences.sortTypes, id: \.self) { method in
                            Text(String(describing: method))
                        }
                    }
                    Picker("Default comment sort method", selection: self.userPreferences.$commentSortMethod) {
                        ForEach(CommentSortType.allCases, id: \.self) { method in
                            Text(String(describing: method))
                        }
                    }
                    Picker("Default listing type", selection: self.userPreferences.$listType) {
                        ForEach(ListingType.allCases, id: \.self) { method in
                            Text(String(describing: method))
                        }
                    }
                    Spacer()
                    Text("NSFW")
                    Toggle("Show NSFW content", isOn: self.userPreferences.$showNsfw)
                    Toggle("Blur NSFW content", isOn: self.userPreferences.$blurNsfw)
                case preferenceOptions[1]:
                    Toggle("Cross Instance Search", isOn: self.userPreferences.$experimentXInstanceSearch)
                    Text("Use '@instance.name' at the end of the search query, to search other Lemmy instances.")
                default:
                    Text("")
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
        }
        .task {
            self.currentSelection = self.preferenceOptions[0]
        }
    }
}

struct PreferenceOption: Hashable {
    let name: String
    let icon: String
    let color: Color
}
