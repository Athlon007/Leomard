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
    let person: Person
    let aggregates: PersonAggregates
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    if person.banner != nil {
                        AsyncImage(url: URL(string: person.banner!)!, content: { phase in
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
                                        alignment: .top
                                    )
                                    .scaledToFit()
                            default:
                                EmptyView()
                            }
                        })
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                    }
                    PersonAvatar(person: person, size: 120)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 35)
                        .padding(.leading, 10)
                }
                Spacer()
                VStack {
                    if person.displayName != nil {
                        Text(person.displayName!)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 24))
                        Text(person.name + "@" + LinkHelper.stripToHost(link: person.actorId))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    } else {
                        Text(person.name)
                         .bold()
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .font(.system(size: 24))
                        Text(person.name + "@" + LinkHelper.stripToHost(link: person.actorId))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .padding(.top, -20)
                Spacer()
                HStack(spacing: 25) {
                    HStack {
                        HStack(spacing: 7) {
                            Image(systemName: "doc.plaintext")
                            Text(String(aggregates.postCount))
                        }
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.up")
                            Text(String(aggregates.postScore))
                        }
                    }
                    HStack {
                        HStack(spacing: 7) {
                            Image(systemName: "message")
                            Text(String(aggregates.commentCount))
                        }
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.up")
                            Text(String(aggregates.commentScore))
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
                        DateDisplayView(date: person.published, noBrackets: true, noTapAction: true)
                    }
                    HStack(spacing: 7) {
                        Image(systemName: "birthday.cake")
                        DateDisplayView(date: person.published, showRealTime: true, noBrackets: true, noTapAction: true, prettyFormat: true)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
                .padding(.top, -20)
                Spacer()
                if person.bio != nil {
                    let banner = MarkdownContent(person.bio!)
                    Markdown(banner)
                        .padding()
                    Spacer()
                }
            }
            .background(Color(.textBackgroundColor))
        }
    }
}
