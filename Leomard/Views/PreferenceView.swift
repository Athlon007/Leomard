//
//  PreferenceView.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

struct FrequencyOption: Hashable, Equatable {
    let name: String
    let seconds: Int
}

struct PreferencesView: View {
    @StateObject var userPreferences: UserPreferences = UserPreferences()
    
    let preferenceOptions: [PreferenceOption] = [
        .init(name: "General", icon: "gearshape", color: .blue),
        .init(name: "Content", icon: "text.alignleft", color: .cyan),
        .init(name: "Experimental", icon: "testtube.2", color: .red)
    ]
    @State var currentSelection: PreferenceOption?
    
    let notificationCheckFrequencies: [FrequencyOption] = [
        .init(name: "Never", seconds: -1),
        .init(name: "10 seconds", seconds: 10),
        .init(name: "30 seconds", seconds: 30),
        .init(name: "1 minute", seconds: 60),
        .init(name: "3 minutes", seconds: 60 * 3),
        .init(name: "10 minutes", seconds: 60 * 10)
    ]
    @State var selectedNotificaitonCheckFrequency: FrequencyOption = .init(name: "Err", seconds: 60)

    
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
                    Picker("Check notifications every", selection: $selectedNotificaitonCheckFrequency) {
                        ForEach(self.notificationCheckFrequencies, id: \.self) { option in
                            /*@START_MENU_TOKEN@*/Text(option.name)/*@END_MENU_TOKEN@*/
                        }
                    }
                    .onChange(of: selectedNotificaitonCheckFrequency) { value in
                        self.userPreferences.checkNotifsEverySeconds = value.seconds
                    }
                case self.preferenceOptions[1]:
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
                case preferenceOptions[2]:
                    Toggle("Cross Instance Search", isOn: self.userPreferences.$experimentXInstanceSearch)
                    Text("""
                         Use '@instance.name' at the end of the search query, to search using other Lemmy instance from your own.
                         Example: 'awesome post @lemmy.world'
                         """)
                        .frame(maxWidth: .infinity)
                        .lineLimit(nil)
                default:
                    Text("")
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity)
        }
        .task {
            self.currentSelection = self.preferenceOptions[0]
        
            for notificationCheckFrequency in notificationCheckFrequencies {
                if userPreferences.checkNotifsEverySeconds == notificationCheckFrequency.seconds {
                    selectedNotificaitonCheckFrequency = notificationCheckFrequency
                    break
                }
            }
            if selectedNotificaitonCheckFrequency.name == "Err" {
                selectedNotificaitonCheckFrequency = notificationCheckFrequencies[3]
            }
        }
    }
}

struct PreferenceOption: Hashable {
    let name: String
    let icon: String
    let color: Color
}
