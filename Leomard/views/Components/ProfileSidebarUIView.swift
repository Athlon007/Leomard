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
    //let person: Person
    //let aggregates: PersonAggregates
    let personView: PersonView
    
    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .bottomLeading) {
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
                    PersonAvatar(person: personView.person, size: 120)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .bottomLeading
                        )
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .padding(.bottom, 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                VStack {
                    if personView.person.displayName != nil {
                        Text(personView.person.displayName!)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 24))
                        Text(personView.person.name + "@" + LinkHelper.stripToHost(link: personView.person.actorId))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    } else {
                        Text(personView.person.name)
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
                .padding(.top, -20)
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
                    Spacer()
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .background(Color(.textBackgroundColor))
        }
    }
}
