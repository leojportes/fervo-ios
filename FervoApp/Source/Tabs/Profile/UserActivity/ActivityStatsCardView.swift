//
//  ActivityStatsCardView.swift
//  FervoApp
//
//  Created by AI Assistant on 12/19/24.
//

import SwiftUI

struct ActivityStatsCardView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(spacing: 12) {
                HStack(spacing: 20) {                    
                    // Nível com troféu
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.levelColor)
                        Text(viewModel.userLevel)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Mini progress bar
                        VStack(spacing: 2) {
                            if !viewModel.isMaxLevel {
                                ProgressView(value: viewModel.progressToNextLevel)
                                    .progressViewStyle(LinearProgressViewStyle(tint: viewModel.levelColor))
                                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
                                    .frame(width: 60)
                                
                                Text("\(viewModel.totalRoles)/\(viewModel.nextLevelThreshold)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Nível máximo!")
                                    .font(.system(size: 9))
                                    .foregroundColor(viewModel.levelColor)
                            }
                        }
                    }
                    
                    // Total de rolês
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.totalRoles)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Total de rolês")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 16)
                
                // Local mais frequentado
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rolê favorito do mês")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    if let favoritePlace = viewModel.mostFrequentedPlaceThisMonth {
                        HStack(spacing: 12) {
                            // Foto do local
                            RemoteImage(url: URL(string: favoritePlace.location.photoURL))
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(favoritePlace.location.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text("\(favoritePlace.count) \(favoritePlace.count == 1 ? "vez" : "vezes")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    } else {
                        Text("Nenhum rolê no último mês")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.FVColor.headerCardbackgroundColor)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    ActivityStatsCardView(viewModel: ProfileViewModel())
        .background(Color.fvBackground)
}
