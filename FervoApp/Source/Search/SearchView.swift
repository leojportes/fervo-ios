//
//  SearchView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var peopleResults: [String] = []
    @Published var placesResults: [String] = []

    private let allPeople = ["Leonardo Portes", "Leonardo da Rosa", "Leonardo Silva", "Leonardo Souza"]
    private let allPlaces = ["Don't Tell Mama", "Bar do Zé", "Clube 21", "Floripa Pub"]

    func searchPeople(query: String) {
        if query.isEmpty {
            peopleResults = []
        } else {
            peopleResults = allPeople.filter { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func searchPlaces(query: String) {
        if query.isEmpty {
            placesResults = []
        } else {
            placesResults = allPlaces.filter { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}

import SwiftUI

struct PeoplePlacesView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedTab: Tab = .pessoas
    @State private var peopleQuery: String = ""
    @State private var placesQuery: String = ""

    enum Tab {
        case pessoas
        case lugares
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header com título
            HStack {
                Text("Explorar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.FVColor.backgroundDark)

            // Abas estilo Capsule
            HStack {
                Spacer()
                Button(action: {
                    selectedTab = .pessoas
                }) {
                    Text("Pessoas")
                        .font(.subheadline)
                        .foregroundColor(selectedTab == .pessoas ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(selectedTab == .pessoas ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }

                Button(action: {
                    selectedTab = .lugares
                }) {
                    Text("Lugares")
                        .font(.subheadline)
                        .foregroundColor(selectedTab == .lugares ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(selectedTab == .lugares ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal)

            // Conteúdo
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if selectedTab == .pessoas {
                        SearchSection(
                            placeholder: "Buscar pessoas...",
                            text: $peopleQuery,
                            results: viewModel.peopleResults,
                            onSearch: { viewModel.searchPeople(query: peopleQuery) }
                        )
                    } else {
                        SearchSection(
                            placeholder: "Buscar lugares...",
                            text: $placesQuery,
                            results: viewModel.placesResults,
                            onSearch: { viewModel.searchPlaces(query: placesQuery) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.fvBackground)
        .navigationBarBackButtonHidden()
    }
}

struct SearchSection: View {
    let placeholder: String
    @Binding var text: String
    let results: [String]
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField(placeholder, text: $text, onCommit: onSearch)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(12)
            .background(Color.FVColor.headerCardbackgroundColor)
            .cornerRadius(10)

            // Lista de resultados
            if results.isEmpty {
                Text("Nenhum resultado encontrado")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(results, id: \.self) { item in
                    Text(item)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.FVColor.headerCardbackgroundColor)
                        .cornerRadius(8)
                }
            }
        }
    }
}
