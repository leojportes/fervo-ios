//
//  DashboardTabView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct DashboardTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var selectedUserModel: UserModel? = nil
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                contentView(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    }
                    .tag(tab)
            }
        }
        .onAppear {
            customizeTabBar()
            customizeNavigationBar()
        }
        .accentColor(.white)
    }

    private func contentView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            return AnyView(
                HomeView(selectedTab: $selectedTab, selectedUserModel: $selectedUserModel ) 
                    .environmentObject(userSession)
                    .environmentObject(loginViewModel)
            )
            //  case .groups:
            //      return AnyView(VStack{ })
        case .meetups:
            return AnyView(VStack{})
        case .profile:
            return AnyView(
                ProfileView(userModel: nil)
                    .environmentObject(userSession)
                    .environmentObject(loginViewModel)
            )
        }
    }

}

extension DashboardTabView {
    private func customizeTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        _ = UIVisualEffectView(effect: blurEffect)
        appearance.backgroundEffect = blurEffect
        appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

enum Tab: String, CaseIterable {
    case home
  //  case groups
    case meetups
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
      //  case .groups: return "Grupos"
        case .meetups: return "Rolês"
        case .profile: return "Você"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
      //  case .groups: return "person.3"
        case .meetups: return "ticket"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
       // case .groups: return "person.3.fill"
        case .meetups: return "ticket.fill"
        case .profile: return "person.fill"
        }
    }
}
