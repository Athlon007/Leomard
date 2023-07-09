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
    
    @State private var lemmyInstance: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoginFailed: Bool = false
    
    var body: some View {
        VStack {
            Text("Lemmy Instance")
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .leading
                )
            TextField("Lemmy Instance", text: $lemmyInstance)
            Text("Username or e-mail")
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .leading
                )
            TextField("Username or e-mail", text: $username)
            Text("Password")
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .leading
                )
            SecureField("Password", text: $password)
            Button("Login", action: login)
                .buttonStyle(.borderedProminent)
            if isLoginFailed {
                Text("Unable to login. Check your login info and try again")
                    .foregroundColor(.red)
            }
        }
        .padding(.trailing, 10)
        .padding(.leading, 10)
        .task {
            loadRecommendedInstances()
        }
    }
    
    func login() {
        let loginService: LoginService = LoginService(requestHandler: requestHandler, sessionService: sessionService)
        let login = Login(usernameOrEmail: self.username, password: self.password, totp2faToken: "")
        loginService.login(lemmyInstance: self.lemmyInstance, login: login) { result in
            switch (result) {
            case .success(let loginResponse):
                let sessionInfo: SessionInfo = SessionInfo(loginResponse: loginResponse, lemmyInstance: lemmyInstance)
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
                print(instances)
            case .failure(let error):
                print(error)
            }
        }
    }
}
