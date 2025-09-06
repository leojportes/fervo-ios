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
                ScrollView(showsIndicators: false) {
                    VStack {
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
                .navigationDestination(isPresented: $isSearchViewPresented) {
                    PeoplePlacesView(userSession: userSession)
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
                    viewModel.fetch()
                }
                customizeNavigationBar()
            }
        }
    }

    private func currentUserHasCheckedIn() -> Bool {
        viewModel.currentUserHasActiveCheckin(firebaseUid: userSession.currentUser?.firebaseUid ?? .empty)
    }
}

// MARK: - Subviews
private extension HomeView {
    var headerView: some View {
        HStack {
            if currentUserHasCheckedIn() {
                
            }
            Spacer()

            Button(action: handleLogout) {
                Label("LOGOUT", systemImage: "magnifyingglass")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    var searchTappedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { isSearchViewPresented = true }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bora sair para um rolê?")
                        .font(.headline)
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
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.FVColor.headerCardbackgroundColor)
                            .opacity(0.5)
                    )
                }
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
