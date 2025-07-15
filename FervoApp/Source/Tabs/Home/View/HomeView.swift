//
//  HomeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Dependencies
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var loginViewModel: LoginViewModel

    @StateObject private var viewModel = HomeViewModel()

    @State var selectedPostForComments: Post?
    @State private var selectedLocation: LocationWithPosts?

    // MARK: - Actions
    @State var isSearchViewPresented: Bool = false
    @State var isShowingLocationDetail: Bool = false
    @State var isCommentsSheetPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                ScrollView {
                    searchTappedView

                    Divider()
                        .background(Color.gray.opacity(0.2))
                        .padding(.horizontal)
                        .padding(.bottom)

                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(viewModel.locationsWithPosts, id: \.id) { location in
                            locationSection(for: location)
                        }
                    }
                    .bottomSheet(item: $selectedPostForComments) { post in
                        CommentsBottomSheetView(postId: post.id)
                    }
                    .coordinateSpace(name: "scroll")
                    .sheet(isPresented: $isSearchViewPresented) {
                        SearchView()
                    }
                    .navigationDestination(item: $selectedLocation) { location in
                        PlaceView(location: location)
                    }
                }

            }
            .background(Color.FVColor.backgroundDark)
            .navigationBarBackButtonHidden()
            .onAppear() {
                viewModel.fetch()
                customizeNavigationBar()
            }
        }
    }

    // MARK: - View Components
    private var headerView: some View {
        HStack {
            if let avatar = userSession.userProfileImage {
                avatar
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .shimmering()
            }

            if let name = userSession.currentUser?.name {
                Text("Olá, \(name)!")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            Spacer()
            Button(action: {
                self.userSession.signOut { success in
                    if success {
                        loginViewModel.isAuthenticated = false
                        FervoAppApp.resetApp()
                    } else {
                        print("❌ Logout falhou")
                    }
                }
            }) {
                Label("LOGOUT", systemImage: "magnifyingglass")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var searchTappedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                isSearchViewPresented = true
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Qual o rolê de hoje?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        Text("Busque um local ou uma pessoa...")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.FVColor.headerCardbackgroundColor).opacity(0.5)
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.FVColor.cardBackground)
                )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func locationSection(for location: LocationWithPosts) -> some View {
        Section(
            header: StickyHeaderView(location: location) {
                DispatchQueue.main.async {
                    self.selectedLocation = location
                }
            }
        ) {
            ForEach(Array(location.lastThreePosts.enumerated()), id: \.element.id) { index, post in
                let isLast = index == location.lastThreePosts.count - 1
                PostCardView(post: post, onCommentTapped: {
                    self.selectedPostForComments = post
                    self.isCommentsSheetPresented = true
                })
                .padding(.horizontal)
                .padding(.top, 12)

                if isLast {
                    Button("Ver mais em \(location.fixedLocation.name)") {
                        self.selectedLocation = location
                    }
                    .font(.subheadline)
                    .padding(.vertical, 16)
                }
            }
        }
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

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
