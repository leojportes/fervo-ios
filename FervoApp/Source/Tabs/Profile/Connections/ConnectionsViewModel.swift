//
//  ConnectionsViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 29/08/25.
//

import Foundation
import Combine
import FirebaseAuth

final class ConnectionsViewModel: ObservableObject {
    @Published var connectedUsers: [UserModel] = []
    @Published var isFetchingConnectedUsers = false
    private var cancellables = Set<AnyCancellable>()

    func fetchConnectedUsers(for uid: String) {
        guard !isFetchingConnectedUsers else { return }
        isFetchingConnectedUsers = true

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }

            if let error = error {
                print("Erro ao obter token: \(error.localizedDescription)")
                return
            }

            guard let token = token else {
                print("Token inválido")
                return
            }

            // Monta a URL dependendo se passou UID ou não
            let urlString = "\(baseIPForTest)/connections/connected/uuid?uid=\(uid)"

            guard let url = URL(string: urlString) else {
                print("URL inválida")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let decoder = JSONDecoder()
            // decoder.dateDecodingStrategy = .iso8601 // se precisar para datas

            URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [UserModel].self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        print("Erro ao buscar usuários conectados: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] users in
                    self?.connectedUsers = users
                    self?.isFetchingConnectedUsers = false
                }
                .store(in: &self.cancellables)
        }
    }

}
