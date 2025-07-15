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
    let userModel: UserModel?  // Agora é let, parâmetro da view
    @Environment(\.dismiss) private var dismiss

    enum ProfileTab {
        case feed
        case atividades
    }

    // Computed property para escolher qual usuário mostrar
    private var userToShow: UserModel? {
        userModel ?? userSession.currentUser
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if userModel != nil {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .background(Color.FVColor.backgroundDark)
            }

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

                if userSession.currentUser?.firebaseUid == userToShow?.firebaseUid {
                    Button(action: {
                        print("Solicitações")
                    }) {
                        Text("Solicitações")
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal)

            // Connections and posts
            HStack(spacing: 40) {
                VStack {
                    Text("24")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("conexões")
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
            }
            .padding(.horizontal)

            // Tabs
            HStack {
                Button(action: {
                    selectedTab = .feed
                }) {
                    Text("Feed")
                        .font(.subheadline)
                        .foregroundColor(selectedTab == .feed ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(selectedTab == .feed ? Color.FVColor.headerCardbackgroundColor : Color.clear)
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
                        .background(selectedTab == .atividades ? Color.FVColor.headerCardbackgroundColor : Color.clear)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal)

            ScrollView {
                switch selectedTab {
                case .feed: makePostView()
                case .atividades: makeAtivittyView()
                }
            }
        }
        .background(Color.fvBackground)
        .onAppear {
            if let user = userToShow {
                viewModel.fetchUserPosts(firebaseUID: user.firebaseUid)
                customizeNavigationBar()
            }
        }
        .navigationBarBackButtonHidden()
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

    func makePostView() -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.posts) { post in
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
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(.horizontal)
    }

    func makeAtivittyView() -> some View {
        VStack {
            Text("Nenhuma atividade no momento")
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
