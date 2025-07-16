//
//  CommentsViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI
import FirebaseAuth

class CommentsViewModel: ObservableObject {
    @Published var comments: [PostComment] = []

    /// Busca os comentários do post com autenticação
    func fetchComments(for postID: String) {
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

            self.performFetchComments(postID: postID, token: token)
        }
    }

    private func performFetchComments(postID: String, token: String) {
        guard let url = URL(string: "http://localhost:8080/posts-by-id/\(postID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erro na requisição: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
                print("📄 Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "desconhecido")")
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateStr = try container.decode(String.self)
                    if let date = formatter.date(from: dateStr) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                }

                let post = try decoder.decode(Post.self, from: data)
                DispatchQueue.main.async {
                    self.comments = post.comments ?? []
                }
            } catch {
                print("⚠️ Erro ao decodificar JSON:", error)
            }
        }.resume()
    }


    /// Envia um comentário autenticado
    func sendComment(postID: String, userID: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performSendComment(postID: postID, userID: userID, text: text, token: token, completion: completion)
        }
    }

    private func performSendComment(postID: String, userID: String, text: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://suaapi.com/posts/\(postID)/comment") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = [
            "user_id": userID,
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

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Erro ao comentar", code: -2)))
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }.resume()
    }
}
