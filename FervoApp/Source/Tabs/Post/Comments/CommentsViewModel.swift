//
//  CommentsViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI
import FirebaseAuth
import Combine

class CommentsViewModel: ObservableObject {
    @Published var comments: [PostComment] = []
    private var cancellables = Set<AnyCancellable>()

    func fetchComments(for postID: String) {
        guard let url = URL(string: "\(baseIPForTest)/posts-by-id/\(postID)") else {
            print("[❌] URL inválida")
            return
        }

        print("[➡️] Iniciando fetch de locationsWithPosts: \(url)")


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
            .decode(type: Post.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    print("[❌] Erro ao decodificar: \(error)")
                case .finished:
                    print("[✅] Decodificação e atualização concluídas")
                }
            } receiveValue: { [weak self] comments in
                print("[🗺️] Locations recebidas: \(comments.comments?.count)")
                self?.comments = comments.comments ?? []
            }
            .store(in: &cancellables)
    }

    func sendComment(postID: String, firebaseUID: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performSendComment(postID: postID, firebaseUID: firebaseUID, text: text, token: token, completion: completion)
        }
    }

    private func performSendComment(postID: String, firebaseUID: String, text: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/comments") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = [
            "post_id": postID,
            "firebase_uid": firebaseUID,
            "text": text
        ]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Resposta inválida", code: -2)))
                return
            }

            // Sucesso esperado: 201 Created
            if httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao comentar. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
