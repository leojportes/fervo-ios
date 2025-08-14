//
//  SearchPeopleViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var peopleResults: [String] = []
    @Published var placesResults: [FixedLocation] = []

    private let allPeople = ["Leonardo Portes", "Leonardo da Rosa", "Leonardo Silva", "Leonardo Souza"]

    private var allPlaces: [FixedLocation] = []
    private var cancellables = Set<AnyCancellable>()

    func searchPeople(query: String) {
        if query.isEmpty {
            peopleResults = []
        } else {
            peopleResults = allPeople.filter { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func fetchPlacesAndSearch(query: String) {
        guard let url = URL(string: "\(baseIPForTest)/fixedlocations") else {
            print("[❌] URL inválida")
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .map { data -> Data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("[📄] JSON recebido: \(jsonString)")
                }
                return data
            }
            .decode(type: [FixedLocation].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("[❌] Erro ao buscar locais: \(error.localizedDescription)")
                    self.placesResults = []
                case .finished:
                    break
                }
            }, receiveValue: { locations in
                print("[🗺️] Locations decodificadas: \(locations.count)")
                self.allPlaces = locations
                self.filterPlaces(query: query)
            })
            .store(in: &cancellables)
    }


    private func filterPlaces(query: String) {
        if query.isEmpty {
            placesResults = allPlaces
        } else {
            let normalizedQuery = normalize(query)
            placesResults = allPlaces.filter { location in
                let normalizedName = normalize(location.name)
                return normalizedName.contains(normalizedQuery)
            }
        }
    }

    private func normalize(_ string: String) -> String {
        let allowedChars = CharacterSet.alphanumerics.union(.whitespaces)
        return string
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: allowedChars.inverted)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
