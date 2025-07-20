//
//  HomeViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import Foundation
import Combine
import Firebase

class HomeViewModel: ObservableObject {
    @Published var locationsWithPosts: [LocationWithPosts] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetch() {
        guard let url = URL(string: "http://127.0.0.1:8080/locations-with-posts") else {
            self.errorMessage = "URL inválida"
            print("[❌] URL inválida")
            return
        }

        print("[➡️] Iniciando fetch de locationsWithPosts: \(url)")

        isLoading = true
        errorMessage = nil

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(receiveSubscription: { _ in
                print("[📡] Requisição iniciada")
            }, receiveOutput: { output in
                if let response = output.response as? HTTPURLResponse {
                    print("[✅] Status Code: \(response.statusCode)")
                }
                print("[📦] Dados recebidos: \(output.data.count) bytes")
            }, receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("[🎯] Requisição finalizada com sucesso")
                case .failure(let error):
                    print("[❌] Falha na requisição: \(error)")
                }
            }, receiveCancel: {
                print("[⚠️] Requisição cancelada")
            })
            .map { $0.data }
            .decode(type: [LocationWithPosts].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Erro: \(error.localizedDescription)"
                    print("[❌] Erro ao decodificar: \(error)")
                case .finished:
                    print("[✅] Decodificação e atualização concluídas")
                }
            } receiveValue: { [weak self] locations in
                print("[🗺️] Locations recebidas: \(locations.count)")
                self?.locationsWithPosts = locations
            }
            .store(in: &cancellables)
    }

    func likePost(postID: String, firebaseUID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performLikeDislikePost(postID: postID, token: token, isLike: true, completion: completion)
        }
    }

    func dislikePost(postID: String, firebaseUID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performLikeDislikePost(postID: postID, token: token, isLike: false, completion: completion)
        }
    }

    private func performLikeDislikePost(postID: String, token: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        // Define a URL diferente para like ou dislike
        let endpoint = "http://127.0.0.1:8080/likes/\(postID)"

        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = Data() // corpo vazio

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
                completion(.failure(NSError(domain: "Erro ao \(isLike ? "curtir" : "descurtir"). Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
