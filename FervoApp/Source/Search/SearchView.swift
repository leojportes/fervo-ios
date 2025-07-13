//
//  SearchView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var isLoading = false
    @State private var selectedTab: Tab = .people

    enum Tab: String, CaseIterable, Identifiable {
        case people, posts, places
        var id: String { rawValue }
    }

    var body: some View {
        VStack {
            profileHeader()

            Divider()

            ScrollView {
                Group {
                    switch selectedTab {
                    case .people: SearchPeopleView()
                    case .posts:  VStack{ }
                        // SearchPostsView()
                    case .places: VStack{ }
                        //SearchPlacesView()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            //  loadInitialData()
        }

    }

    @ViewBuilder
    private func profileHeader() -> some View {
        HStack {
            ForEach(Tab.allCases) { tab in
                ProfileTabButton(
                    title: tabTitle(for: tab),
                    tab: tab,
                    selectedTab: $selectedTab
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }

    private func tabTitle(for tab: Tab) -> String {
        switch tab {
        case .people: return "Pessoas"
        case .posts: return "Posts"
        case .places: return "Lugares"
        }
    }

    private func loadInitialData() {
        isLoading = true
        // Simular carregamento:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
}

struct ProfileTabButton: View {
    let title: String
    let tab: SearchView.Tab
    @Binding var selectedTab: SearchView.Tab

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Text(title)
                .fontWeight(.medium)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .animation(.easeInOut, value: selectedTab)
        }
    }
}
