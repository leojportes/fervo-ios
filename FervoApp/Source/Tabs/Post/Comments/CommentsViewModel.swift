//
//  CommentsViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comments: [PostComment] = []

    func fetchComments(for postID: String) {
        guard let url = URL(string: "https://suaapi.com/posts/\(postID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let post = try JSONDecoder().decode(Post.self, from: data)
                DispatchQueue.main.async {
                    self.comments = post.comments ?? []
                }
            } catch {
                print("Erro ao decodificar comentários:", error)
            }
        }.resume()
    }

    func sendComment(postID: String, userID: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://suaapi.com/posts/\(postID)/comment") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

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
