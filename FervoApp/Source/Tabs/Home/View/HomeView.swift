//
//  HomeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

//
//  HomeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Dependencies
    @Binding var selectedTab: Tab
    @Binding var selectedUserModel: UserModel?
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var loginViewModel: LoginViewModel

    // MARK: - ViewModel
    @EnvironmentObject var viewModel: HomeViewModel

    // MARK: - State
    @State private var selectedPostForComments: Post?
    @State private var selectedLocation: LocationWithPosts?
    @State private var selectedPostToNavigateProfile: Post?
    @State private var isSearchViewPresented: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                ScrollView {
                    VStack {
                        sectionTitle
                        searchTappedView
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .background(Color.FVColor.backgroundDark)
                    
                    postsList
                }
                .refreshable {
                    viewModel.fetch()
                }
                .background(Color.FVColor.backgroundDark)
                .coordinateSpace(name: "scroll")
                .sheet(item: $selectedPostForComments) { post in
                    CommentsBottomSheetView(
                        userSession: userSession,
                        postId: post.id,
                        onDisappear: { hasNewComment in
                            if hasNewComment {
                                viewModel.fetch()
                            }
                        }
                    )
                }
                .sheet(isPresented: $isSearchViewPresented) {
                    PeoplePlacesView()
                }
                .navigationDestination(item: $selectedLocation) { location in
                    PlaceView(location: location, userSession: userSession)
                }
                .navigationDestination(item: $selectedPostToNavigateProfile) { userModel in
                    ProfileView(userModel: userModel.userPost)
                }
            }
            .background(Color.FVColor.backgroundDark)
            .navigationBarBackButtonHidden()
            .onAppear {
                DispatchQueue.main.async {
                    if viewModel.locationsWithPosts.isEmpty {
                        viewModel.fetch()
                    }
                }
                customizeNavigationBar()
            }
        }
    }
}

// MARK: - Subviews
private extension HomeView {
    var headerView: some View {
        HStack {
            // MARK: - Avatar e Nome do Usuário (comentado para futura implementação)
            /*
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
            */

            Spacer()

            Button(action: handleLogout) {
                Label("LOGOUT", systemImage: "magnifyingglass")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    var sectionTitle: some View {
        HStack {
            Text("Explorar")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color.FVColor.backgroundDark)
    }

    var searchTappedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { isSearchViewPresented = true }) {
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
                            .fill(Color.FVColor.headerCardbackgroundColor)
                            .opacity(0.5)
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

    var postsList: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            ForEach(viewModel.locationsWithPosts, id: \.id) { location in
                locationSection(for: location)
            }
        }
    }

    @ViewBuilder
    func locationSection(for location: LocationWithPosts) -> some View {
        Section(
            header: StickyHeaderView(location: location) {
                DispatchQueue.main.async {
                    selectedLocation = location
                }
            }
        ) {
            ForEach(Array(location.lastThreePosts.enumerated()), id: \.element.id) { index, post in
                let isLast = index == location.lastThreePosts.count - 1

                PostCardView(
                    post: post,
                    onCommentTapped: {
                        selectedPostForComments = post
                    },
                    onLikeTapped: {
                        viewModel.fetch()
                    },
                    onPostTapped: {
                        handlePostTap(post)
                    }
                )
                .environmentObject(userSession)
                .padding(.horizontal)
                .padding(.top, 12)
                .blurLoading(viewModel.isLoading)

                if isLast {
                    Button("Ver mais em \(location.fixedLocation.name)") {
                        selectedLocation = location
                    }
                    .font(.subheadline)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

// MARK: - Actions
private extension HomeView {
    func handleLogout() {
        userSession.signOut { success in
            if success {
                loginViewModel.isAuthenticated = false
                FervoAppApp.resetApp()
            } else {
                print("❌ Logout falhou")
            }
        }
    }

    func handlePostTap(_ post: Post) {
        if post.userPost.firebaseUid == userSession.currentUser?.firebaseUid {
            selectedUserModel = post.userPost
            selectedTab = .profile
        } else {
            selectedPostToNavigateProfile = post
        }
    }

    func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
