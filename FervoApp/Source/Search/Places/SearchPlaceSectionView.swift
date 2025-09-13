//
//  SearchPlaceSectionView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 08/09/25.
//

import SwiftUI

struct SearchPlaceSectionView: View {
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
