//
//  ProfileViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import Foundation
import Combine
import FirebaseAuth

final class ProfileViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var connectedUsers: [UserModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasConnection: Bool = false
    @Published var hasPendingConnections: Bool = false
    @Published var pendingConnectionId: String? = nil


    private var cancellables = Set<AnyCancellable>()
    private var isFetching: Bool = false
    private var isFetchingConnectedUsers = false


    func fetchUserPosts(firebaseUID: String) {
        guard !isFetching else { return }  // evita chamadas concorrentes
        isFetching = true
        isLoading = true

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            defer { self.isFetching = false }  // libera a flag ao final da execução

            if let error = error {
                self.errorMessage = "Erro ao obter token: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let token = token else {
                self.errorMessage = "Token inválido"
                self.isLoading = false
                return
            }

            self.performRequest(firebaseUID: firebaseUID, token: token)
        }
    }

    private func performRequest(firebaseUID: String, token: String) {
        guard var components = URLComponents(string: "\(baseIPForTest)/posts/by-user") else {
            self.errorMessage = "URL inválida"
            self.isLoading = false
            return
        }

        components.queryItems = [URLQueryItem(name: "firebase_uid", value: firebaseUID)]

        guard let url = components.url else {
            self.errorMessage = "URL inválida com query"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("🔵 JSON bruto recebido: \(jsonString)")
                }
            })
            .map(\.data)
            .decode(type: [Post].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &cancellables)
    }

    func checkConnection(with otherUserUID: String, completion: ((Bool) -> Void)? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            self.hasConnection = false
            completion?(false)
            return
        }

        let urlString = "\(baseIPForTest)/connections/check/\(otherUserUID)"
        guard let url = URL(string: urlString) else {
            print("URL inválida: \(urlString)")
            self.hasConnection = false
            completion?(false)
            return
        }

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            if let error = error {
                print("Erro ao pegar token: \(error.localizedDescription)")
                self.hasConnection = false
                completion?(false)
                return
            }

            guard let token = token else {
                print("Token é nulo")
                self.hasConnection = false
                completion?(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Erro na requisição: \(error.localizedDescription)")
                        self.hasConnection = false
                        completion?(false)
                        return
                    }

                    guard let data = data else {
                        print("Resposta sem dados")
                        self.hasConnection = false
                        completion?(false)
                        return
                    }

                    do {
                        // Decodifica JSON e extrai campo connected
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let connected = json?["connected"] as? Bool ?? false

                        self.hasConnection = connected
                        completion?(connected)
                    } catch {
                        print("Erro ao decodificar JSON: \(error.localizedDescription)")
                        self.hasConnection = false
                        completion?(false)
                    }
                }
            }.resume()
        }
    }

    func fetchPendingConnections(userIdToCheck: String) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("[❌] Erro ao obter token: \(error)")
                return
            }

            guard let token = token else {
                print("[❌] Token inválido")
                return
            }

            self.performFetchPendingConnections(token: token, userIdToCheck: userIdToCheck)
        }
    }

    private func performFetchPendingConnections(token: String, userIdToCheck: String) {
        guard let url = URL(string: "\(baseIPForTest)/connections/pending") else {
            print("[❌] URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if response.statusCode == 200 {
                    return result.data
                } else {
                    // Tentar extrair mensagem de erro do corpo
                    if let errorResponse = try? JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any],
                       let message = errorResponse["message"] as? String {
                        throw NSError(domain: "APIError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                    } else {
                        throw NSError(domain: "APIError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Status code \(response.statusCode)"])
                    }
                }
            }
            .decode(type: [PendingConnection].self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("[❌] Falha ao buscar pendentes: \(error.localizedDescription)")
                case .finished:
                    print("[✅] Conexões pendentes carregadas")
                }
            } receiveValue: { [weak self] connections in
                self?.hasPendingConnections = !connections.filter({ $0.from.firebaseUid == userIdToCheck && $0.status == "pending" }).isEmpty
                self?.pendingConnectionId = connections
                    .first(where: { $0.from.firebaseUid == userIdToCheck && $0.status == "pending" })?.id
            }
            .store(in: &cancellables)
    }

    func acceptConnection(connectionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performAcceptConnection(connectionID: connectionID, token: token, completion: completion)
        }
    }

    private func performAcceptConnection(connectionID: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/connections/\(connectionID)/accept") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Resposta inválida", code: -2)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.hasConnection = true
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao aceitar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    func fetchConnectedUsers() {
           guard !isFetchingConnectedUsers else { return }
            isFetchingConnectedUsers = true

           Auth.auth().currentUser?.getIDToken { [weak self] token, error in
               guard let self = self else { return }
               defer { self.isFetchingConnectedUsers = false }

               if let error = error {
                   print("Erro ao obter token: \(error.localizedDescription)")
                   return
               }

               guard let token = token else {
                   print("Token inválido")
                   return
               }

               guard let url = URL(string: "\(baseIPForTest)/connections/connected") else {
                   print("URL inválida")
                   return
               }

               var request = URLRequest(url: url)
               request.httpMethod = "GET"
               request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
               request.cachePolicy = .reloadIgnoringLocalCacheData

               let decoder = JSONDecoder()
               // Configure o decoder para datas se necessário, exemplo:
               // decoder.dateDecodingStrategy = .iso8601

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
                   }
                   .store(in: &self.cancellables)
           }
       }
}
