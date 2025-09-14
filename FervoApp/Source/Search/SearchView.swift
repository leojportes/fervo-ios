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
    @State private var selectedUser: UserModel? 

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
                        SearchPeopleSectionView(
                            placeholder: "Buscar pessoas...",
                            text: $peopleQuery,
                            viewModel: viewModel,
                            results: viewModel.peopleResults,
                            onSearch: { viewModel.fetchUserAndSearch(query: peopleQuery) },
                            onGoToUserPage: { user in selectedUser = user }
                        )
                    } else {
                        SearchPlaceSectionView(
                            placeholder: "Buscar lugares...",
                            text: $placesQuery,
                            viewModel: viewModel,
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
        .navigationDestination(item: $selectedUser) { user in
            ProfileView(userModel: user)
                .environmentObject(userSession)
        }
        .background(Color.fvBackground)
        .navigationBarBackButtonHidden()

    }
}
