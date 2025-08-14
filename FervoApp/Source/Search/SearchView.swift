//
//  SearchView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

struct PeoplePlacesView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedTab: Tab = .peoples
    @State private var peopleQuery: String = ""
    @State private var placesQuery: String = ""
    @Environment(\.dismiss) private var dismiss
    var onSelectLocation: ((FixedLocation) -> Void)? = nil

    enum Tab {
        case peoples
        case places
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            HStack {
                Spacer()
                Button(action: {
                    selectedTab = .peoples
                }) {
                    Text("Pessoas")
                        .font(.subheadline)
                        .foregroundColor(selectedTab == .peoples ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(selectedTab == .peoples ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }

                Button(action: {
                    selectedTab = .places
                }) {
                    Text("Lugares")
                        .font(.subheadline)
                        .foregroundColor(selectedTab == .places ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(selectedTab == .places ? Color.FVColor.headerCardbackgroundColor : Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if selectedTab == .peoples {
                        SearchSection(
                            placeholder: "Buscar pessoas...",
                            text: $peopleQuery,
                            results: viewModel.peopleResults,
                            onSearch: { viewModel.searchPeople(query: peopleQuery) }
                        )
                    } else {
                        SearchPlaceSection(
                            placeholder: "Buscar lugares...",
                            text: $placesQuery,
                            results: viewModel.placesResults,
                            onSearch: { viewModel.fetchPlacesAndSearch(query: placesQuery) },
                            onTapLocation: { location in
                                dismiss()
                                onSelectLocation?(location)
                            }
                        )
                        .onAppear {
                            viewModel.fetchPlacesAndSearch(query: "")
                        }
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

struct SearchPlaceSection: View {
    let placeholder: String
    @Binding var text: String
    let results: [FixedLocation]
    let onSearch: () -> Void
    var onTapLocation: (FixedLocation) -> Void

    var body: some View {
        VStack(spacing: 12) {
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

            if results.isEmpty {
                Text("Nenhum resultado encontrado")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(results, id: \.self) { item in
                    Button(action: {
                        onTapLocation(item)
                    }, label: {
                        Text(item.name)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.FVColor.headerCardbackgroundColor)
                            .cornerRadius(8)
                    })
                }
            }
        }
    }
}
