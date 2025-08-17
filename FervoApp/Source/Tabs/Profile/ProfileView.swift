//
//  ProfileView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: ProfileTab = .feed
    @State private var isPresentSolicitations = false
    let userModel: UserModel?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUserFromSolicitations: UserModel? = nil
    @State private var selectedPostIndex: Int = 0
    @State private var isShowingPostCarousel = false

    enum ProfileTab {
        case feed
        case atividades
    }

    private var userToShow: UserModel? {
        userModel ?? userSession.currentUser
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if userModel != nil {
                HStack(alignment: .center) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.vertical)
                    }

                    Text("@\(userToShow?.username ?? "")")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(Color.FVColor.backgroundDark)
                    Spacer()
                    if userSession.currentUser?.firebaseUid == userToShow?.firebaseUid {
                        Button(action: {
                            isPresentSolicitations = true
                        }) {
                            Text("Solicitações")
                                .font(.subheadline)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.FVColor.backgroundDark)
            } else {
                HStack {
                    Text("@\(userSession.currentUser?.username ?? "")")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                    if userSession.currentUser?.firebaseUid == userToShow?.firebaseUid {
                        Button(action: {
                            isPresentSolicitations = true
                        }) {
                            Text("Solicitações")
                                .font(.subheadline)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.FVColor.backgroundDark)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        if let url = userToShow?.image?.photoURL {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 60, height: 60)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .shimmering()
                            }
                        }
                        if let user = userToShow {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(user.age) anos")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    // Connections and posts
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(viewModel.connectedUsers.count)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(viewModel.connectedUsers.count == 1 ? "Conexão" : "Conexões")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        VStack {
                            Text("\(viewModel.posts.count)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Posts")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    if viewModel.hasConnection || userSession.currentUser?.firebaseUid == userToShow?.firebaseUid {
                        HStack(alignment: .center) {
                            Spacer()
                            Button(action: {
                                selectedTab = .feed
                            }) {
                                Text("Feed")
                                    .font(.subheadline)
                                    .foregroundColor(selectedTab == .feed ? .white : .gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(selectedTab == .feed ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.1))
                                    .clipShape(Capsule())
                            }

                            Button(action: {
                                selectedTab = .atividades
                            }) {
                                Text("Atividades")
                                    .font(.subheadline)
                                    .foregroundColor(selectedTab == .atividades ? .white : .gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(selectedTab == .atividades ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)


                    switch selectedTab {
                    case .feed:
                        if userSession.currentUser?.firebaseUid == userToShow?.firebaseUid || viewModel.hasConnection {
                            makePostView()
                        } else {
                            conditionalContent()
                        }
                    case .atividades:
                        if userSession.currentUser?.firebaseUid == userToShow?.firebaseUid || viewModel.hasConnection {
                            makeAtivittyView()
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedUserFromSolicitations) { user in
            ProfileView(userModel: user)
        }
        .sheet(isPresented: $isPresentSolicitations) {
            SolicitationsView(userSession: userSession, onGoToUserPage: { user in
                selectedUserFromSolicitations = user
            })
        }
        .background(Color.fvBackground)
        .onAppear {
            onAppearMethods()
        }
        .navigationBarBackButtonHidden()
    }


    private func conditionalContent() -> some View {
        if viewModel.hasPendingConnections {
            AnyView(
                HStack {
                    if let username = userToShow?.username {
                        Text("\(username) quer se conectar com você")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        if let id = viewModel.pendingConnectionId {
                            viewModel.acceptConnection(connectionID: id) { result in
                                switch result {
                                case .success(_):
                                    onAppearMethods()
                                case .failure(_):
                                    print("")
                                }
                            }
                        }
                    }) {
                        Text("Confirmar")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .padding()
                })
        } else {
            AnyView(
                VStack {
                    Text("Esse perfil é privado.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
    }

    private func onAppearMethods() {
        if let userIdToCheck = userModel?.firebaseUid {
            viewModel.fetchPendingConnections(userIdToCheck: userIdToCheck)
            viewModel.checkConnection(with: userIdToCheck) { result in
                if result {
                    print("tem conexão? \(result)")
                }
            }
        }
        if let user = userToShow {
            viewModel.fetchUserPosts(firebaseUID: user.firebaseUid)
            viewModel.fetchConnectedUsers()
        }
        customizeNavigationBar()
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

    @ViewBuilder
    func makePostView() -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        if viewModel.posts.isEmpty {
            emptyView(text: "Nenhuma postagem para mostrar.")
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    GeometryReader { geometry in
                        AsyncImage(url: URL(string: post.image.photoURL ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .shimmering()
                        }
                        .frame(width: geometry.size.width, height: 140)
                        .clipped()
                        .contentShape(Rectangle()) // Para o clique pegar a área toda
                        .onTapGesture {
                            print("Post clicado index: \(index), total posts: \(viewModel.posts.count)")
                            selectedPostIndex = index
                            isShowingPostCarousel = true
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $isShowingPostCarousel) {
                PostCarouselView(posts: viewModel.posts, selectedIndex: $selectedPostIndex) {
                    isShowingPostCarousel = false
                }
                .environmentObject(userSession)
            }
        }
    }

    func makeAtivittyView() -> some View {
        emptyView(text: "Nenhuma atividade no momento")
    }

    func emptyView(text: String) -> some View {
        VStack {
            Text(text)
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//            .environmentObject(UserSession()) // Adiciona o ambiente necessário
//    }
//}

struct PostCarouselView: View {
    let posts: [Post]
    @EnvironmentObject var userSession: UserSession
    @Binding var selectedIndex: Int
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding([.horizontal, .top], 10)
                }
                .frame(width: 30)

                Spacer()
                VStack(alignment: .center) {
                    Text("Posts")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Text("@\(posts.first?.userPost.username ?? "")")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                Rectangle()
                    .foregroundColor(Color.fvBackground)
                    .frame(width: 30, height: 10)

                Spacer()
            }
            .background(Color.fvBackground)
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            VStack {
                                PostCardView(
                                    post: post,
                                    onCommentTapped: {
                                        //selectedPostForComments = post
                                    },
                                    onLikeTapped: {
                                        // viewModel.fetch()
                                    },
                                    onPostTapped: {
                                        //handlePostTap(post)
                                    }
                                )
                                .environmentObject(userSession)
                                .padding(.horizontal)
                                .padding(.top, 12)
                            }
                            .padding(.top, 12)
                            .padding(.bottom, index == posts.count - 1 ? 150 : 0)
                            .clipped()
                            .id(index)
                            .background(Color.black)
                        }
                    }

                }
                .background(Color.fvBackground)
                .ignoresSafeArea()
                .onAppear {
                    proxy.scrollTo(selectedIndex, anchor: .bottom)
                }
            }
        }
        .background(Color.fvBackground)
    }
}


