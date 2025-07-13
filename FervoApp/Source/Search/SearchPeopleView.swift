//
//  SearchPeopleView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

struct SearchPeopleView: View {
    @State private var searchText: String = ""
//    @StateObject private var searchPeopleViewModel = SearchPeopleViewModel()

    var filteredUsersToConnect: [UserToConnect] {
        return [.init(id: "", firebaseUID: "", username: "adsdsa", name: "dasda", email: "dad", image: .init(imageId: "", photoURL: ""))]
//
//        else {
//           return searchPeopleViewModel.users.filter {
//               $0.username.lowercased().contains(searchText.lowercased())
//           }
//       }
    }

    var body: some View {
        VStack {
            TextField("Buscar pessoas...", text: $searchText)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)

            if filteredUsersToConnect.isEmpty {
                Text("Nenhum usuário encontrado")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUsersToConnect) { user in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle("Pessoas")
        .onAppear {
           // searchPeopleViewModel.fetchUsers()
        }
    }
}
