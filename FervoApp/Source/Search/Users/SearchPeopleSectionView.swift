//
//  SearchPeopleSectionView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import SwiftUI

struct SearchPeopleSectionView: View {
    let placeholder: String
    @Binding var text: String
    @StateObject var viewModel: SearchViewModel
    let results: [SearchPeopleModel]
    let onSearch: () -> Void
    var onGoToUserPage: ((UserModel) -> Void)?

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
                    Text("Buscando usuário...")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                if results.isEmpty && !viewModel.isFetchingPlaces {
                    Text("Nenhum resultado encontrado")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(results, id: \.self) { result in
                        HStack(alignment: .top, spacing: 12) {
                            Button(action: {
                                onGoToUserPage?(result.user)
                            }) {
                                HStack {
                                    AsyncImage(url: URL(string: result.user.image?.photoURL ?? .empty)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                            .shadow(radius: 2)
                                    } placeholder: {
                                        Color.gray.opacity(0.3).frame(width: 40, height: 40).clipShape(Circle())
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.user.name)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        HStack {
                                            Text("@\(result.user.username)")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)

                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
}
