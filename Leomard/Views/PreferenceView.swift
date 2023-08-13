//
//  PreferenceView.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

fileprivate struct FrequencyOption: Hashable, Equatable {
    let name: String
    let seconds: Int
}

struct PreferencesView: View {
    let checkForUpdateMethod: () -> Void
    
    fileprivate let preferenceOptions: [PreferenceOption] = [
        .init(name: "General", icon: "gearshape", color: .blue),
        .init(name: "Content", icon: "text.alignleft", color: .cyan),
        .init(name: "Display", icon: "display", color: .teal),
        .init(name: "Updates", icon: "square.and.arrow.down.on.square", color: .green),
        .init(name: "Experiments", icon: "testtube.2", color: .red)
    ]
    @State fileprivate var currentSelection: PreferenceOption?
    
    fileprivate let notificationCheckFrequencies: [FrequencyOption] = [
        .init(name: "Never", seconds: -1),
        .init(name: "10 seconds", seconds: 10),
        .init(name: "30 seconds", seconds: 30),
        .init(name: "1 minute", seconds: 60),
        .init(name: "3 minutes", seconds: 60 * 3),
        .init(name: "10 minutes", seconds: 60 * 10)
    ]
    @State fileprivate var selectedNotificaitonCheckFrequency: FrequencyOption = .init(name: "Err", seconds: 60)
    @State var manuallyCheckedForUpdate: Bool = false
    
    @State fileprivate var selectedViewType: ViewModeOption = .singleColumn
    @State fileprivate var selectedPostDisplayOption: PostDisplayOption = .card
    
    @State var helpText: String = ""
    @State var showHelp: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationSplitView {
            preferencesSidebar
                .listStyle(SidebarListStyle())
                .navigationBarBackButtonHidden(true)
        } detail: {
            preferencePanel(for: currentSelection)
                .padding(.leading)
                .padding(.trailing)
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
        }
        .task {
            self.currentSelection = self.preferenceOptions[0]
            
            for notificationCheckFrequency in notificationCheckFrequencies {
                if UserPreferences.getInstance.checkNotifsEverySeconds == notificationCheckFrequency.seconds {
                    selectedNotificaitonCheckFrequency = notificationCheckFrequency
                    break
                }
            }
            if selectedNotificaitonCheckFrequency.name == "Err" {
                selectedNotificaitonCheckFrequency = notificationCheckFrequencies[3]
            }
            
            self.selectedViewType = UserPreferences.getInstance.twoColumnView ? .twoColumns : .singleColumn
            self.selectedPostDisplayOption = UserPreferences.getInstance.usePostCompactView ? .compact : .card
        }
        .overlay {
            helpOverlay
        }
    }
    
    // MARK: - Sidebar
    
    @ViewBuilder
    private var preferencesSidebar: some View {
        List {
            ForEach(preferenceOptions, id: \.self) { option in
                preferenceSidebarItem(option: option)
                    .padding(.bottom, 10)
                    .onTapGesture {
                        self.currentSelection = option
                    }
            }
        }
    }
    
    @ViewBuilder
    private func preferenceSidebarItem(option: PreferenceOption) -> some View {
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
            .shadow(radius: 0.5)
            Text(option.name)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .foregroundColor(currentSelection == option ? Color(.linkColor) : Color(.labelColor))
            Spacer()
        }
    }
    
    // MARK: - Detail
    
    @ViewBuilder
    private func preferencePanel(for currentSelection: PreferenceOption?) -> some View {
        List {
            VStack(alignment: .leading, spacing: 20) {
                switch currentSelection {
                case preferenceOptions[0]:
                    generalPreferences
                case preferenceOptions[1]:
                    contentPreferences
                case preferenceOptions[2]:
                    displayPreferences
                case preferenceOptions[3]:
                    updatesPreferences
                case preferenceOptions[4]:
                    experimentalPreferences
                default:
                    Text("")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var generalPreferences: some View {
        VStack{
            Picker("Check notifications every", selection: $selectedNotificaitonCheckFrequency) {
                ForEach(self.notificationCheckFrequencies, id: \.self) { option in
                    Text(option.name)
                }
            }
            .onChange(of: selectedNotificaitonCheckFrequency) { value in
                UserPreferences.getInstance.checkNotifsEverySeconds = value.seconds
            }
        }
        VStack(alignment: .leading) {
            Text("Inbox")
            Toggle("Show Unread only by default", isOn: UserPreferences.getInstance.$unreadonlyWhenOpeningInbox)
        }
        GroupBox("Prefer Display Name") {
            VStack {
                Text("Communities")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("Posts", isOn: UserPreferences.getInstance.$preferDisplayNameCommunityPost)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("Followed", isOn: UserPreferences.getInstance.$preferDisplayNameCommunityFollowed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
            VStack {
                Toggle("People", isOn: UserPreferences.getInstance.$preferDisplayNamePeoplePost)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .leading) {
            Toggle("Autosave post drafts", isOn: UserPreferences.getInstance.$autosavePostCreation)
        }
    }
    
    @ViewBuilder
    private var contentPreferences: some View {
        VStack(alignment: .leading) {
            Picker("Default post sort method", selection: UserPreferences.getInstance.$postSortMethod) {
                ForEach(UserPreferences.getInstance.sortTypes, id: \.self) { method in
                    Text(String(describing: method).spaceBeforeCapital())
                }
            }
            Picker("Default comment sort method", selection: UserPreferences.getInstance.$commentSortMethod) {
                ForEach(CommentSortType.allCases, id: \.self) { method in
                    Text(String(describing: method))
                }
            }
            Picker("Default listing type", selection: UserPreferences.getInstance.$listType) {
                ForEach(ListingType.allCases, id: \.self) { method in
                    Text(String(describing: method))
                }
            }
            Picker("Default profile sort method", selection: UserPreferences.getInstance.$profileSortMethod) {
                ForEach(UserPreferences.getInstance.profileSortTypes, id: \.self) { method in
                    Text(String(describing: method).spaceBeforeCapital())
                }
            }
        }
        GroupBox("NSFW") {
            Toggle("Show NSFW content", isOn: UserPreferences.getInstance.$showNsfw)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("Show NSFW content in Feed", isOn: UserPreferences.getInstance.$showNsfwInFeed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            Toggle("Blur NSFW content", isOn: UserPreferences.getInstance.$blurNsfw)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox("Mark Post As Read") {
            Toggle("When opening the post", isOn: UserPreferences.getInstance.$markPostAsReadOnOpen)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("When voting on post", isOn: UserPreferences.getInstance.$markPostAsReadOnVote)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("When viewed in feed", isOn: UserPreferences.getInstance.$markPostAsReadOnDisappear)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        VStack {
            Toggle("Hide Read Posts", isOn: UserPreferences.getInstance.$hideReadPosts)
        }
        VStack(alignment: .leading) {
            Text("Hidden Instances")
            TextField("Hidden Instances", text: UserPreferences.getInstance.$blockedInstances, prompt: Text("ex.: instance1.com, instance2.org"))
                .textFieldStyle(.roundedBorder)
            Text("Any instances listed here will be filtered out. You won't see communities, posts, or comments from those instances. Simply type the hostname of the instance (comma-separated).")
                .lineLimit(nil)
        }
        VStack(alignment: .leading) {
            HStack {
                Toggle("Use Piped.video for YouTube videos", isOn: UserPreferences.getInstance.$usePipedVideoForYoutube)
                Button("?", action: {
                    self.helpText = """
                # Use Piped.video for YouTube
                Piped.video is an alternative privacy friendly YouTube frontend.
                """
                    self.showHelp = true
                })
                .cornerRadius(360)
            }
        }
    }
    
    @ViewBuilder
    private var displayPreferences: some View {
        GroupBox("Post Display") {
            VStack {
                VStack {
                    Image(nsImage: NSImage(imageLiteralResourceName: colorScheme == .dark ? "CardViewDark" : "CardView"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            UserPreferences.getInstance.usePostCompactView = false
                            selectedPostDisplayOption = .card
                        }
                    Picker("", selection: $selectedPostDisplayOption) {
                        Text("Card").tag(PostDisplayOption.card)
                    }
                    .onChange(of: selectedPostDisplayOption) { value in
                        if value == PostDisplayOption.card {
                            UserPreferences.getInstance.usePostCompactView = false
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(.bottom, 8)
                }
                Divider()
                VStack {
                    Image(nsImage: NSImage(imageLiteralResourceName: colorScheme == .dark ? "CompactViewDark" : "CompactView"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            UserPreferences.getInstance.usePostCompactView = true
                            selectedPostDisplayOption = .compact
                        }
                    Picker("", selection: $selectedPostDisplayOption) {
                        Text("Compact").tag(PostDisplayOption.compact)
                    }
                    .onChange(of: selectedPostDisplayOption) { value in
                        if value == PostDisplayOption.compact {
                            UserPreferences.getInstance.usePostCompactView = true
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(.bottom, 8)
                }
            }
        }
        GroupBox("Open Posts In") {
            VStack {
                VStack {
                    Image(nsImage: NSImage(imageLiteralResourceName: colorScheme == .dark ? "PopupViewDark" : "PopupView"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            UserPreferences.getInstance.twoColumnView = false
                            selectedViewType = .singleColumn
                        }
                    Picker("", selection: $selectedViewType) {
                        Text("Popup").tag(ViewModeOption.singleColumn)
                    }
                    .onChange(of: selectedViewType) { value in
                        if value == ViewModeOption.singleColumn {
                            UserPreferences.getInstance.twoColumnView = false
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(.bottom, 8)
                }
                Divider()
                VStack {
                    Image(nsImage: NSImage(imageLiteralResourceName: colorScheme == .dark ? "TwoColumnViewDark" : "TwoColumnView"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            UserPreferences.getInstance.twoColumnView = true
                            selectedViewType = .twoColumns
                        }
                    Picker("", selection: $selectedViewType) {
                        Text("Second Column").tag(ViewModeOption.twoColumns)
                    }
                    .onChange(of: selectedViewType) { value in
                        if value == ViewModeOption.twoColumns {
                            UserPreferences.getInstance.twoColumnView = true
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(.bottom, 8)
                }
            }
        }
        GroupBox("Followed List") {
            Toggle("Show Letter Separators", isOn: UserPreferences.getInstance.$navbarShowLetterSeparators)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("Show Communities Instances", isOn: UserPreferences.getInstance.$showCommunitiesInstances)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .leading) {
            Toggle("Truncate Post Titles", isOn: UserPreferences.getInstance.$truncatePostTitles)
        }
    }
    
    @ViewBuilder
    private var updatesPreferences: some View {
        VStack(alignment: .leading) {
            Picker("Check for updates", selection: UserPreferences.getInstance.$checkForUpdateFrequency) {
                ForEach(UpdateFrequency.allCases, id: \.self) { option in
                    Text(String(describing: option))
                }
            }
            HStack(spacing: 10) {
                Button("Check for update", action: {
                    self.checkForUpdateMethod()
                    manuallyCheckedForUpdate = true
                })
                .disabled(manuallyCheckedForUpdate)
                Text("Last updated:")
                DateDisplayView(date: UserPreferences.getInstance.lastUpdateCheckDate, showRealTime: true, noBrackets: true, noTapAction: true)
                if manuallyCheckedForUpdate {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private var experimentalPreferences: some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("Store liked posts locally", isOn: UserPreferences.getInstance.$saveLikedPosts)
                Button("?", action: {
                    self.helpText = """
# Store liked posts locally
Liked posts will be saved into your session, which then can be browsed in your Profile view under **Liked** posts.

Leomard does not know which posts you liked in other apps, and will add them if either you see that post in, or you like one in Leomard only.

The information about what you like is securely stored on your device.
"""
                    self.showHelp = true
                })
                .cornerRadius(360)
            }
        }
    }
    
    @ViewBuilder
    private var helpOverlay: some View {
        if showHelp {
            ZStack {
                Color(white: 0, opacity: 0.33)
                    .onTapGesture {
                        showHelp = false
                    }
                    .ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button("Dismiss", action: { showHelp = false })
                                .buttonStyle(.link)
                            Spacer()
                                .buttonStyle(.link)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        let content = MarkdownContent(helpText)
                        Markdown(content)
                            .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
                .padding()
                .frame(maxWidth: 400, minHeight: 0, maxHeight: 250)
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
                .cornerRadius(8)
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
            }
        }
    }
}

fileprivate struct PreferenceOption: Hashable {
    let name: String
    let icon: String
    let color: Color
}

fileprivate enum ViewModeOption {
    case singleColumn
    case twoColumns
}

fileprivate enum PostDisplayOption {
    case card
    case compact
}
