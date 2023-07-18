//
//  ProfileView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let commentService: CommentService
    let contentView: ContentView
    let person: Person
    @Binding var myself: MyUserInfo?
    
    @State var personDetails: GetPersonDetailsResponse? = nil
    
    @State var postService: PostService? = nil
    @State var personService: PersonService? = nil
    @State var browseOptions: [Option] = [
        .init(id: 0, title: "Comments", imageName: "message"),
        .init(id: 1, title: "Posts", imageName: "doc.plaintext"),
    ]
    @State var selectedBrowseOption: Option = Option(id: 0, title: "Comments", imageName: "message")
    
    @State var page: Int = 1
    
    @State var currentSessionId: UUID = SessionStorage.getInstance.getCurrentSession()?.id ?? UUID()
    @State var sessions: [SessionInfo] = []
    
    var body: some View {
        HStack {
            if person != myself?.localUserView.person {
                Button("Dismiss", action: contentView.dismissProfileView)
                    .buttonStyle(.link)
            }
            Spacer()
            HStack {
                HStack {
                    Image(systemName: selectedBrowseOption.imageName)
                        .padding(.trailing, 0)
                    Picker("", selection: $selectedBrowseOption) {
                        ForEach(browseOptions, id: \.self) { method in
                            Text(method.title)
                        }
                    }
                    .frame(maxWidth: 120)
                    .padding(.leading, -10)
                    .onChange(of: selectedBrowseOption) { value in
                        self.reloadFeed()
                    }
                }
                Button(action: reloadFeed) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            Spacer()
            HStack {
                if person == myself?.localUserView.person {
                    Picker("", selection: $currentSessionId ) {
                        ForEach(sessions, id: \.self.id) { session in
                            Text("\(session.name)@\(session.lemmyInstance)")
                        }
                        Divider()
                        Text("Add New")
                    }
                    .onChange(of: $currentSessionId) { change in
                        self.performSwitch(change)
                    }
                    .frame(maxWidth: 120)
                    Button("Logout", action: logout)
                }
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity
        )
        .padding(.leading)
        .padding(.trailing)
        VStack {
            GeometryReader { proxy in
                HStack {
                    ScrollViewReader { scrollProxy in
                        List {
                            if personDetails != nil {
                                if proxy.size.width < 1000 {
                                    VStack {
                                        ProfileSidebarUIView(personView: personDetails!.personView, myself: $myself)
                                    }
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity
                                    )
                                    .cornerRadius(4)
                                    .padding(.bottom, 15)
                                }
                                switch selectedBrowseOption.id {
                                case 0:
                                    if personDetails?.comments == [] {
                                        Text("No comments found!")
                                            .italic()
                                            .foregroundColor(.secondary)
                                    }
                                    ForEach(personDetails!.comments, id: \.self) { commentView in
                                        VStack {
                                            CommentUIView(commentView: commentView, indentLevel: 1, commentService: commentService, myself: $myself, post: commentView.post, contentView: contentView, profileViewMode: true)
                                                .onAppear {
                                                    if commentView == personDetails!.comments.last {
                                                        self.loadPersonDetails()
                                                    }
                                                }
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: .infinity
                                                )
                                                .padding(.top, 15)
                                                .padding(.bottom, 15)
                                                .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color(.textBackgroundColor))
                                        .cornerRadius(4)
                                        .onTapGesture {
                                            self.loadPostFromComment(commentView: commentView)
                                        }
                                        Spacer()
                                            .frame(height: 0)
                                        
                                    }
                                default:
                                    if personDetails?.posts == [] {
                                        Text("No posts found!")
                                            .italic()
                                            .foregroundColor(.secondary)
                                    }
                                    ForEach(personDetails!.posts, id: \.self) { postView in
                                        PostUIView(postView: postView, shortBody: true, postService: self.postService!, myself: $myself, contentView: contentView)
                                            .onAppear {
                                                if postView == personDetails!.posts.last {
                                                    self.loadPersonDetails()
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        Spacer()
                                            .frame(height: 0)
                                    }
                                    
                                }
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: 600,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    }
                    
                    if proxy.size.width > 1000 {
                        List {
                            VStack {
                                if personDetails != nil {
                                    ProfileSidebarUIView(personView: personDetails!.personView, myself: $myself)
                                }
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity
                            )
                            .cornerRadius(4)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: 400,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
        .cornerRadius(4)
        .task {
            if person == myself?.localUserView.person {
                browseOptions.append(Option(id: 2, title: "Saved", imageName: "star"))
            }
            
            let requestHandler = RequestHandler()
            self.postService = PostService(requestHandler: requestHandler)
            self.personService = PersonService(requestHandler: requestHandler)
            loadPersonDetails()
        }
        Spacer()
    }
    
    func logout() {
        _ = SessionStorage.getInstance.endSession()
        contentView.navigateToFeed()
        contentView.logout()
    }
    
    func loadPersonDetails() {
        if page == 1 && self.personDetails != nil {
            self.personDetails!.comments = []
            self.personDetails!.posts = []
        }
        
        self.personService?.getPersonDetails(person: person, page: page, savedOnly: selectedBrowseOption.id == 2) { result in
            switch result {
            case .success(let personDetails):
                DispatchQueue.main.sync {
                    if self.personDetails != nil {
                        self.personDetails!.posts += personDetails.posts
                        self.personDetails!.comments += personDetails.comments
                    } else {
                        self.personDetails = personDetails
                    }
                    if self.personDetails?.personView.person == myself?.localUserView.person {
                        loadSessions()
                    }
                }
                
                page += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func reloadFeed() {
        page = 1
        loadPersonDetails()
    }
    
    func loadPostFromComment(commentView: CommentView) {
        self.postService?.getPostForComment(comment: commentView.comment) { result in
            switch result {
            case .success(let getPostResponse):
                self.contentView.openPost(postView: getPostResponse.postView)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadSessions() {
        if self.sessions.count == 0 {
            self.sessions = SessionStorage.getInstance.getAllSessions()
        }
    }
    
    func performSwitch(_ sel: SessionInfo) {
        print(sel)
    }
}
