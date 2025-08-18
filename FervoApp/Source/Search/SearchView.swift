//
//  SearchView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

struct PeoplePlacesView: View {
    let userSession: UserSession
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedTab: Tab = .places
    @State private var peopleQuery: String = ""
    @State private var placesQuery: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLocation: LocationWithPosts?

    enum Tab {
        case peoples
        case places
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding([.horizontal], 10)
                }

                Text("Explorar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal)
            .background(Color.FVColor.backgroundDark)
            .frame(height: 50)

            HStack {
                Spacer()
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
                Spacer()
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal)

            ScrollView(.vertical, showsIndicators: true) {
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
                            text: $placesQuery, viewModel: viewModel,
                            onSearch: { viewModel.fetchPlacesAndSearch(query: placesQuery) },
                            onTapLocation: { location in
                                selectedLocation = location
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
        .navigationDestination(item: $selectedLocation) { item in
            PlaceView(location: item, userSession: userSession)
        }
        .background(Color.fvBackground)
        .navigationBarBackButtonHidden()

    }
}
//self.selectedLocation = LocationWithPosts(fixedLocation: location, posts: [])
//self.isSearchViewPresented = false

struct SearchSection: View {
    let placeholder: String
    @Binding var text: String
    let results: [UserModel]
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
                    Text(item.name)
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
    @StateObject var viewModel: SearchViewModel
    let onSearch: () -> Void
    var onTapLocation: (LocationWithPosts) -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    TextField("", text: $text, onCommit: onSearch)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .padding(12)
            .background(Color.FVColor.headerCardbackgroundColor)
            .cornerRadius(10)

            if viewModel.isFetchingPlaces {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.3)
                    Text("Buscando lugares...")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                if viewModel.placesResults.isEmpty {
                    Text("Nenhum resultado encontrado")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    let placesResults = viewModel.placesResults.sorted { $0.placeIsOpen && !$1.placeIsOpen }

                    ForEach(placesResults.indices, id: \.self) { index in
                        let item = placesResults[index]

                        PlaceResultCardView(location: item) {
                            DispatchQueue.main.async {
                                onTapLocation(item)
                            }
                        }
                        .padding(.bottom, index == placesResults.count - 1 ? 32 : 0)
                    }
                }
            }
        }
        .background(Color.FVColor.backgroundDark)
        .task {
            viewModel.fetchPlacesAndSearch(query: text)
        }
    }
}
