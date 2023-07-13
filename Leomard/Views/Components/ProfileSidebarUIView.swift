//
//  ProfileSidebarUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 05/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct ProfileSidebarUIView: View {
    let personView: PersonView
    @Binding var myself: MyUserInfo?
    
    @State var writingMessage: Bool = false
    @State var messageText: String = ""
    @State var isSendingMessage: Bool = false
    
    var body: some View {
        LazyVStack {
            ZStack() {
                if personView.person.banner != nil {
                    AsyncImage(url: URL(string: personView.person.banner!)!, content: { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    maxHeight: .infinity,
                                    alignment: .bottom
                                )
                        default:
                            EmptyView()
                        }
                    })
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 150,
                        maxHeight: 150
                    )
                }
                PersonAvatar(person: personView.person, size: 120)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.bottom, -60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            LazyVStack {
                if personView.person.displayName != nil {
                    Text(personView.person.displayName!)
                        .PersonNameFormat(person: personView.person, myself: myself)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 24))
                    Text(personView.person.name + "@" + LinkHelper.stripToHost(link: personView.person.actorId))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                } else {
                    Text(personView.person.name)
                        .PersonNameFormat(person: personView.person, myself: myself)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 24))
                    Text(personView.person.name + "@" + LinkHelper.stripToHost(link: personView.person.actorId))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .padding(.top, 45)
            Spacer()
            HStack(spacing: 25) {
                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: "doc.plaintext")
                        Text(String(personView.counts.postCount))
                    }
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.up")
                        Text(String(personView.counts.postScore))
                    }
                }
                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: "message")
                        Text(String(personView.counts.commentCount))
                    }
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.up")
                        Text(String(personView.counts.commentScore))
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .padding()
            .padding(.top, -20)
            HStack(spacing: 25) {
                HStack(spacing: 7) {
                    Image(systemName: "calendar.badge.plus")
                    DateDisplayView(date: personView.person.published, noBrackets: true, noTapAction: true)
                }
                HStack(spacing: 7) {
                    Image(systemName: "birthday.cake")
                    DateDisplayView(date: personView.person.published, showRealTime: true, noBrackets: true, noTapAction: true, prettyFormat: true)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
            .padding(.top, -20)
            if personView.person != myself?.localUserView.person {
                Spacer()
                HStack {
                    Button(action: startWritePrivateMessage) {
                        Image(systemName: "envelope")
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
                .padding(.top, -20)
            }
            if self.writingMessage {
                Spacer()
                VStack {
                    Text("Private Message")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .fontWeight(.semibold)
                    TextEditor(text: $messageText)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 0.5))
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                        .lineLimit(5...)
                        .font(.system(size: NSFont.preferredFont(forTextStyle: .body).pointSize))
                    HStack {
                        Button("Send", action: onSendMessage)
                            .buttonStyle(.borderedProminent)
                            .frame(
                                alignment: .leading
                            )
                            .disabled(!isSendable())
                        Button("Cancel", action: cancelComment)
                            .buttonStyle(.automatic)
                            .frame(
                                alignment: .leading
                            )
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
                .padding()
                .padding(.top, -20)
            }
            Spacer()
            if personView.person.bio != nil {
                let banner = MarkdownContent(personView.person.bio!)
                Markdown(banner)
                    .lineLimit(nil)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
                    .padding()
                    .padding(.top, -20)
                Spacer()
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .background(Color(.textBackgroundColor))
        .contextMenu {
            PersonContextMenu(personView: self.personView)
        }
        
    }
    
    func startWritePrivateMessage() {
        writingMessage = true
    }
    
    func onSendMessage() {
        let requestHandler = RequestHandler()
        let service = PrivateMessageService(requestHandler: requestHandler)
        isSendingMessage = true
        
        service.sendPrivateMessage(content: messageText, recipient: personView.person) { result in
            switch result {
            case .success(let privateMessageResponse):
                service.markAsRead(privateMessage: privateMessageResponse.privateMessageView.privateMessage, read: true) { _ in }
                messageText = ""
                writingMessage = false
                isSendingMessage = false
            case .failure(let error):
                print(error)
                isSendingMessage = false
            }
        }
    }
    
    func cancelComment() {
        messageText = ""
        writingMessage = false
    }
    
    func isSendable() -> Bool {
        return messageText.count > 0 && !isSendingMessage
    }
}
