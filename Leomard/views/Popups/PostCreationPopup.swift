//
//  PostCreationPopup.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation
import SwiftUI

struct PostCreationPopup: View {
    let contentView: ContentView
    let community: Community
    let postService: PostService
    @Binding var myself: MyUserInfo?
    
    @State var title: String = ""
    @State var bodyText: String = ""
    @State var url: String = ""
    @State var isNsfw: Bool = false
    
    var body: some View {
        ZStack {
            VStack {  }
                .frame (
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .background(Color.black)
                .opacity(0.33)
                .onTapGesture {
                    close()
                }
            VStack {
                VStack {
                    HStack {
                        Button("Dismiss", action: close)
                            .buttonStyle(.link)
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                    
                    VStack {
                        Text("Title")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .fontWeight(.semibold)
                        TextField("", text: $title)
                        Text("Body")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .fontWeight(.semibold)
                        TextEditor(text: $bodyText)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 0.5))
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                                maxHeight: .infinity,
                                alignment: .leading
                            )
                            .lineLimit(5...)
                            .font(.system(size: NSFont.preferredFont(forTextStyle: .body).pointSize))
                        Button("Send", action: sendPost)
                            .buttonStyle(.borderedProminent)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .disabled(canSend())
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: 600,
                    minHeight: 0,
                    maxHeight: 750
                )
                .background(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.windowFrameTextColor), lineWidth: 1)
                )
            }
            .cornerRadius(4)
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
    }
    
    func close() {
        contentView.closePost()
    }
    
    func sendPost() {
        
    }
    
    func canSend() -> Bool {
        return false
    }
}
