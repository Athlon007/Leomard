//
//  LoginView.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

struct LoginView: View {
    let sessionService: SessionService
    let requestHandler: RequestHandler
    var contentView: ContentView
        
    @State var url: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isLoginFailed: Bool = false
    @State var instances: [LemmyInstance] = []
    @State var selectedInstance: LemmyInstance? = nil
    
    var body: some View {
        ZStack {
            VStack {
                Text("Leomard")
                    .bold()
                    .font(.system(size: 24))
                List {
                    ForEach(instances, id: \.self) { instance in
                        HStack {
                            VStack{
                                Image(systemName: "person.2.circle")
                                    .AvatarFormatting(size: 50)
                            }
                            VStack {
                                Text(instance.name)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 18))
                                Text(instance.url)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(minWidth: 0, alignment: .center)
                        .onTapGesture {
                            self.url = instance.url
                            selectedInstance = instance
                        }
                        .padding()
                        .cornerRadius(4)
                        .background(selectedInstance == instance ? Color(.selectedContentBackgroundColor) : Color.clear)
                    }
                }.frame(maxWidth: .infinity, maxHeight: 200)
                Text("Lemmy Instance")
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                TextField("lemmy.world", text: $url)
                Text("Username or e-mail")
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                TextField("", text: $username)
                Text("Password")
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                SecureField("", text: $password)
                Button("Login", action: login)
                    .buttonStyle(.borderedProminent)
                if isLoginFailed {
                    Text("Unable to login. Check your login info and try again")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: 600)
            .task {
                loadRecommendedInstances()
            }
            .background(Color(.textBackgroundColor))
            .cornerRadius(4)
        }
    }
    
    func login() {
        let loginService: LoginService = LoginService(requestHandler: requestHandler, sessionService: sessionService)
        let login = Login(usernameOrEmail: self.username, password: self.password, totp2faToken: "")
        loginService.login(lemmyInstance: self.url, login: login) { result in
            switch (result) {
            case .success(let loginResponse):
                let sessionInfo: SessionInfo = SessionInfo(loginResponse: loginResponse, lemmyInstance: url)
                self.sessionService.save(response: sessionInfo)
                self.isLoginFailed = false
                self.contentView.navigateToFeed()
                self.contentView.loadUserData()
            case .failure(let error):
                print(error)
                self.isLoginFailed = true
            }
        }
    }
    
    func loadRecommendedInstances() {
        let loginService: LoginService = LoginService(requestHandler: requestHandler, sessionService: sessionService)
        loginService.getLemmyInstances() { result in
            switch result {
            case .success(let instances):
                self.instances = instances
            case .failure(let error):
                print(error)
            }
        }
    }
}
