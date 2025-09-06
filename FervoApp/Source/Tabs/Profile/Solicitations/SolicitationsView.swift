//
//  SolicitationsView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/07/25.
//

import SwiftUI

struct SolicitationsView: View {
    @StateObject private var viewModel = SolicitationsViewModel()
    let userSession: UserSession
    @Environment(\.dismiss) private var dismiss
    var onGoToUserPage: ((UserModel) -> Void)?
    @State var showTooltip = false
    @State var tooltipMessage: String = ""

    var body: some View {
        VStack {
            HStack {
                 Spacer()
                 Capsule()
                     .frame(width: 30, height: 4)
                     .foregroundColor(.white)
                 Spacer()
             }
             .padding(.top, 12)
             .padding(.bottom, 25)
            ScrollView {
                VStack(alignment: .leading) {
                    if viewModel.pendingConnections.isEmpty && !viewModel.pendingConnectionsIsLoading {
                        Text("Não há nenhuma\nsolicitação de conexão.")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 200)
                            .padding(.bottom, 60)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.gray)
                    } else if !viewModel.pendingConnectionsIsLoading {
                        ForEach(viewModel.pendingConnections, id: \.id) { connections in
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    dismiss()
                                    onGoToUserPage?(connections.from)
                                }) {
                                    HStack {
                                        AsyncImage(url: URL(string: connections.from.image?.photoURL ?? .empty)) { image in
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
                                            Text(connections.from.name)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            HStack {
                                                Text("@\(connections.from.username)")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.white)

                                                Text(connections.createdAt.timeAgoSinceDate)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)

                                                Spacer()
                                            }
                                        }
                                    }
                                }

                                Spacer()

                                HStack(spacing: 6) {
                                    Button(action: {
                                        viewModel.acceptConnection(connectionID: connections.id) { result in
                                            switch result {
                                            case .success(_):
                                                viewModel.fetchPendingConnections()
                                            case .failure(_):
                                                showTooltip = true
                                                tooltipMessage = "Aconteceu algum erro ao se conectar."
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
                                    Button(action: {
                                        viewModel.cancelConnection(connectionID: connections.id) { result in
                                            switch result {
                                            case .success(_):
                                                showTooltip = true
                                                tooltipMessage = "Solicitação de conexão cancelada."
                                                viewModel.fetchPendingConnections()
                                            case .failure(_):
                                                showTooltip = true
                                                tooltipMessage = "Aconteceu algum erro ao cancelar a conexão."
                                                dismiss()
                                            }
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.clear)
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.leading, 12)
                            }
                            .padding(.leading, 16)
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding(.bottom, 50)
            .background(Color.FVColor.backgroundDark.ignoresSafeArea())


            Spacer()
                .background(Color.FVColor.backgroundDark.ignoresSafeArea())

        }
        .onAppear {
            viewModel.fetchPendingConnections()
        }
        .background(Color.FVColor.backgroundDark.ignoresSafeArea())
        .overlay(
            VStack {
                if showTooltip {
                    withAnimation {
                        TooltipView(
                            text: tooltipMessage,
                            onClose: { withAnimation { showTooltip = false } }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .padding(.top, 12)
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        )
    }
}
