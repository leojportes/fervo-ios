//
//  FervoAppApp.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

import SwiftUI
import MapKit

@main
struct FervoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userSession = UserSession()
    @StateObject var loginViewModel = LoginViewModel()
    @State private var appVersion = UUID()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userSession)
                .environmentObject(loginViewModel)
                .id(appVersion)
                .onAppear() {
                    loginViewModel.autoLoginIfNeeded()
                }
        }
    }

    static func resetApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.windows.first?.rootViewController = UIHostingController(
            rootView: RootView()
                .environmentObject(UserSession())
                .environmentObject(LoginViewModel())
        )
        scene.windows.first?.makeKeyAndVisible()
    }
}

struct RootView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var loginViewModel: LoginViewModel
    let manager = CLLocationManager()

    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        Group {
            if loginViewModel.isLoading {
                ProgressView("Verificando autenticação...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
            } else if loginViewModel.isAuthenticated {
                DashboardTabView()
                    .environmentObject(userSession)
                    .environmentObject(loginViewModel)
                    .environmentObject(homeViewModel)
                    .onAppear {
                        manager.requestWhenInUseAuthorization()
                    }
            } else {
                LoginView()
                    .environmentObject(userSession)
                    .environmentObject(loginViewModel)
                    .onAppear {
                        manager.requestWhenInUseAuthorization()
                    }
            }
        }
        .animation(.easeInOut, value: loginViewModel.isAuthenticated)
        .animation(.easeInOut, value: loginViewModel.isLoadingAuthState)
    }
}
