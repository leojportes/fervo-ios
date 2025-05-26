//
//  HomeViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var locationsWithPosts: [LocationWithPosts] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetch() {
        guard let url = URL(string: "http://localhost:8080/locations-with-posts") else {
            self.errorMessage = "URL inválida"
            print("[❌] URL inválida")
            return
        }

        print("[➡️] Iniciando fetch de locationsWithPosts: \(url)")

        isLoading = true
        errorMessage = nil

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
            .decode(type: [LocationWithPosts].self, decoder: JSONDecoder())
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
}
