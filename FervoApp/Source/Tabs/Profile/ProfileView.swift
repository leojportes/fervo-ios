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
    @State private var isPresentConnections = false
    @State var connectionButtonTitle: String = ""

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

                    Text("@\(userToShow?.username ?? .empty)")
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
                    Text("@\(userSession.currentUser?.username ?? .empty)")
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
                .padding(.top, 20)
                .background(Color.FVColor.backgroundDark)
            }
            ScrollView(showsIndicators: false) {
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
                        
                        if !viewModel.hasConnection && userSession.currentUser?.firebaseUid != userToShow?.firebaseUid {
                            Button(action: {
                                self.connectionButtonTitle = "Solicitado"
                                viewModel.requestConnection(toUserID: userToShow?.firebaseUid ?? "") { result in
                                    switch result {
                                    case .success():
                                        print("Solicitação de conexão enviada com sucesso!")
                                        // Atualizar UI ou mostrar mensagem de sucesso
                                        
                                    case .failure(let error):
                                        print("Erro ao solicitar conexão: \(error.localizedDescription)")
                                        // Mostrar erro para o usuário
                                    }
                                }
                            }) {
                                Text(connectionButtonTitle)
                                    .font(.caption)
                                    .foregroundColor(hasSolicitations ? .gray : .white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(hasSolicitations ? Color.blue.opacity(0.4) : Color.blue.opacity(0.8))
                                    .cornerRadius(8)
                            }
                            .disabled(hasSolicitations)
                            .padding() 
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    // Connections and posts
                    HStack(spacing: 40) {
                      
                        VStack(alignment: .center, spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.levelColor)
                            Text(viewModel.userLevel)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                      
                        Button(action: {
                            if viewModel.connectedUsers.count > 0 && (viewModel.hasConnection || userSession.currentUser?.firebaseUid == userToShow?.firebaseUid) {
                                isPresentConnections = true
                            }
                        }) {
                            VStack {
                                Text("\(viewModel.connectedUsers.count)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(viewModel.numberOfonnectionsTitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
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

                    if !viewModel.isLoadingCheckConnection {
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
            }.refreshable(action: {
                onAppearMethods()
            })
        }
        .sheet(item: $selectedUserFromSolicitations) { user in
            ProfileView(userModel: user)
        }
        .sheet(isPresented: $isPresentSolicitations) {
            SolicitationsView(
                userSession: userSession,
                onGoToUserPage: { user in
                    selectedUserFromSolicitations = user
                }
            )
            .onDisappear { 
                onAppearMethods()
            }
        }
        .sheet(isPresented: $isPresentConnections) {
            if let user = userToShow {
                ConnectionsView(
                    userSession: userSession,
                    user: user,
                    onGoToUserPage: { user in
                        selectedUserFromSolicitations = user
                    }
                )
            }
        }
        .background(Color.fvBackground)
        .onAppear {
            onAppearMethods()
        }
        .navigationBarBackButtonHidden()
    }
    
    private var hasSolicitations: Bool {
        connectionButtonTitle == "Solicitado"
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
                                    print("onAppearMethods fail")
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
            viewModel.fetchUserActivityHistory(uid: userIdToCheck)
            viewModel.checkConnection(with: userIdToCheck) { result in
                if result {
                    print("tem conexão? \(result)")
                }
            }
        }
        if let user = userToShow {
            viewModel.fetchUserPosts(firebaseUID: user.firebaseUid)
            viewModel.fetchConnectedUsers(for: user.firebaseUid)
            viewModel.fetchUserActivityHistory(uid: user.firebaseUid)
        }
        self.connectionButtonTitle = viewModel.hasPendingConnections ? "Solicitado" : "Conectar"
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
                        AsyncImage(url: URL(string: post.image.photoURL ?? .empty)) { image in
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
                        .contentShape(Rectangle())
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
                PostCarouselView(isLoading: $viewModel.isLoading, posts: viewModel.posts, selectedIndex: $selectedPostIndex) {
                    isShowingPostCarousel = false
                }
                .environmentObject(userSession)
            }
        }
    }

    func makeAtivittyView() -> some View {
        VStack(alignment: .leading) {
            MusicalTasteBadgesView(user: userToShow)
                .padding(.vertical, 20)
            
            ActivityStatsCardView(viewModel: viewModel)
                .padding(.top, 10)
            
            Text("Últimos rolês")
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            ActivityCarouselView(viewModel: viewModel)

            ActivityChartView(viewModel: viewModel)
                .padding(.bottom, 20)
                .padding(.top, 10)
            
            Spacer()
        }
        
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
