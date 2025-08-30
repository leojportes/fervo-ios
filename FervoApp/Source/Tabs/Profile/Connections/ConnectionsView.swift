//
//  ConnectionsView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 29/08/25.
//

import SwiftUI

struct ConnectionsView: View {
    let connections: [UserModel]
    let userSession: UserSession
    @Environment(\.dismiss) private var dismiss
    var onGoToUserPage: ((UserModel) -> Void)?

    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 30, height: 4)
                .foregroundColor(Color.white)
                .clipShape(Capsule())
                .padding(.bottom, 25)
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading) {
                    if connections.isEmpty {
                        Text("Não há nenhuma\nsolicitação de conexão.")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 200)
                            .padding(.bottom, 60)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(connections, id: \.id) { user in
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    dismiss()
                                    onGoToUserPage?(user)
                                }) {
                                    HStack {
                                        AsyncImage(url: URL(string: user.image?.photoURL ?? "")) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 35, height: 35)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                                .shadow(radius: 2)
                                        } placeholder: {
                                            Color.gray.opacity(0.3).frame(width: 40, height: 40).clipShape(Circle())
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(user.name)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            HStack {
                                                Text("@\(user.username)")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.white)

                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.leading, 16)
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding(.bottom, 50)

            Spacer()

        }
        .onAppear {
            //  viewModel.fetchPendingConnections()
        }
        .background(Color.fvCardBackgorund)
    }
}
