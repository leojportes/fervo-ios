////
////  SearchPeopleViewModel.swift
////  FervoApp
////
////  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
////
//
//import Foundation
//import Combine
//import FirebaseAuth
//
//final class SearchPeopleViewModel: ObservableObject {
//    @Published var usersToConnect: [UserToConnect]? = nil
//    @Published var currentUserId: String? = nil
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        fetchCurrentUserId()
//        fetchAvailableUsersToConnect()
//    }
//
//    /// Busca o ID do usuário atual via Firebase
//    func fetchCurrentUserId() {
//        guard let user = Auth.auth().currentUser else { return }
//        user.getIDTokenResult(completion: { [weak self] result, error in
//            guard let tokenResult = result, error == nil else {
//                print("Erro ao obter token: \(error?.localizedDescription ?? "Erro desconhecido")")
//                return
//            }
//            DispatchQueue.main.async {
//                self?.currentUserId = tokenResult.token
//            }
//        })
//    }
//
//    /// Obtém usuários disponíveis para conexão
//    func fetchAvailableUsersToConnect() {
//        guard let token = Auth.auth().currentUser?.uid else { return }
//
//        let urlString = "https://api.meetus.app/users/available-to-connect"
//        guard let url = URL(string: urlString) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let data = data {
//                do {
//                    let users = try JSONDecoder().decode([UserToConnect].self, from: data)
//                    DispatchQueue.main.async {
//                        self?.usersToConnect = users
//                    }
//                } catch {
//                    print("Erro ao decodificar usuários: \(error.localizedDescription)")
//                }
//            } else if let error = error {
//                print("Erro ao buscar usuários: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//}
