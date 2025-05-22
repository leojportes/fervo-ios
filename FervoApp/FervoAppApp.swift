//
//  FervoAppApp.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

import SwiftUI

@main
struct FervoAppApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            //LoginView()
            DashboardTabView()
        }
    }
}
