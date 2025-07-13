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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchUserPosts() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "Usuário não autenticado"
            return
        }

        isLoading = true
        user.getIDToken { [weak self] token, error in
            guard let self = self else { return }

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

            self.performRequest(firebaseUID: user.uid, token: token)
        }
    }

    private func performRequest(firebaseUID: String, token: String) {
        guard var components = URLComponents(string: "http://\(baseIPForTest):8080/posts/by-user") else {
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
}
