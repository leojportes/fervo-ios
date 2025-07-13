//
//  FervoAppApp.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

import SwiftUI

@main
struct FervoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userSession = UserSession()
    @StateObject var loginViewModel = LoginViewModel()

    var body: some Scene {
        WindowGroup {
            if loginViewModel.isAuthenticated {
                DashboardTabView()
                    .environmentObject(userSession)
            } else {
                LoginView()
                    .environmentObject(userSession)
                    .environmentObject(loginViewModel)
            }
        }
    }
}
