//
//  SearchPeopleViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var peopleResults: [UserModel] = []
    @Published var placesResults: [LocationWithPosts] = []
    @Published var isFetchingPlaces: Bool = false

    private let allPeople: [UserModel] = []

    private var allPlaces: [LocationWithPosts] = []
    private var cancellables = Set<AnyCancellable>()

    // Cache
    private var lastFetchAt: Date?
    private let cacheTTL: TimeInterval = 60 * 5 // 5 minutos

    func fetchPlacesAndSearch(query: String, forceRefresh: Bool = false) {
        // Usa cache se ainda válido
        if !forceRefresh,
           !allPlaces.isEmpty,
           let last = lastFetchAt,
           Date().timeIntervalSince(last) < cacheTTL {
            print("[⚡️] Usando cache de locais")
            filterPlaces(query: query)
            isFetchingPlaces = false
            return
        }

        isFetchingPlaces = true
        guard let url = URL(string: "\(baseIPForTest)/locations-with-posts") else {
            print("[❌] URL inválida")
            isFetchingPlaces = false
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [LocationWithPosts].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isFetchingPlaces = false
                if case let .failure(error) = completion {
                    print("[❌] Erro ao buscar locais: \(error.localizedDescription)")
                    self.placesResults = []
                }
            } receiveValue: { locations in
                print("[🗺️] Locations decodificadas: \(locations.count)")
                self.allPlaces = locations
                self.lastFetchAt = Date()
                self.filterPlaces(query: query)
                self.isFetchingPlaces = false
            }
            .store(in: &cancellables)
    }

    private func filterPlaces(query: String) {
        if query.isEmpty {
            placesResults = allPlaces
        } else {
            let normalizedQuery = normalize(query)
            placesResults = allPlaces.filter { location in
                let normalizedName = normalize(location.fixedLocation.name)
                return normalizedName.contains(normalizedQuery)
            }
        }
    }

    func searchPeople(query: String) {
        if query.isEmpty {
            peopleResults = allPeople
        } else {
            let normalizedQuery = normalize(query)
            peopleResults = allPeople.filter { user in
                normalize(user.name).contains(normalizedQuery)
            }
        }
    }

    private func normalize(_ string: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        return string
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: allowed.inverted)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
