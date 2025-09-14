//
//  SolicitationsViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/07/25.
//
import SwiftUI
import FirebaseAuth
import Combine

struct PendingConnection: Codable, Equatable, Hashable {
    let id: String
    let from: UserModel
    let to: UserModel
    let status: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, from, to, status
        case createdAt = "created_at"
    }
}

class SolicitationsViewModel: ObservableObject {
    @Published var pendingConnections: [PendingConnection] = []
    @Published var pendingConnectionsIsLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Solicitar conexão
    func requestConnection(to userId: String, completion: @escaping (Result<PendingConnection, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performRequestConnection(to: userId, token: token, completion: completion)
        }
    }

    private func performRequestConnection(to userId: String, token: String, completion: @escaping (Result<PendingConnection, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/connections") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["to": userId]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Resposta inválida", code: -2)))
                return
            }

            if httpResponse.statusCode == 201 {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let connection = try decoder.decode(PendingConnection.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(connection))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao solicitar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    // MARK: - Cancelar conexão
    func cancelConnection(connectionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performCancelConnection(connectionID: connectionID, token: token, completion: completion)
        }
    }

    private func performCancelConnection(connectionID: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/connections/\(connectionID)/cancel") else {
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

            if httpResponse.statusCode == 204 {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao cancelar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    // MARK: - Listar conexões pendentes
    func fetchPendingConnections() {
        self.pendingConnectionsIsLoading = true
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("[❌] Erro ao obter token: \(error)")
                self.pendingConnectionsIsLoading = false
                return
            }

            guard let token = token else {
                print("[❌] Token inválido")
                self.pendingConnectionsIsLoading = false
                return
            }

            self.performFetchPendingConnections(token: token)
        }
    }

    private func performFetchPendingConnections(token: String) {
        guard let url = URL(string: "\(baseIPForTest)/connections/pending") else {
            self.pendingConnectionsIsLoading = false
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
                    self.pendingConnectionsIsLoading = false
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
                    self.pendingConnectionsIsLoading = false
                    print("[❌] Falha ao buscar pendentes: \(error.localizedDescription)")
                case .finished:
                    self.pendingConnectionsIsLoading = false
                    print("[✅] Conexões pendentes carregadas")
                }
            } receiveValue: { [weak self] connections in
                self?.pendingConnectionsIsLoading = false
                self?.pendingConnections = connections.filter { $0.from.firebaseUid != Auth.auth().currentUser?.uid }
            }
            .store(in: &cancellables)
    }

    // MARK: - Aceitar conexão
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
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao aceitar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }


}
