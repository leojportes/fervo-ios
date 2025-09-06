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
                    // Total de rolês
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(totalRoles)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Total de rolês")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Nível com troféu
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(levelColor)
                        Text(userLevel)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Mini progress bar
                        VStack(spacing: 2) {
                            if !isMaxLevel {
                                ProgressView(value: progressToNextLevel)
                                    .progressViewStyle(LinearProgressViewStyle(tint: levelColor))
                                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
                                    .frame(width: 60)
                                
                                Text("\(totalRoles)/\(nextLevelThreshold)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Nível máximo!")
                                    .font(.system(size: 9))
                                    .foregroundColor(levelColor)
                            }
                        }
                    }
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
                    
                    if let favoritePlace = mostFrequentedPlaceThisMonth {
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
    
    // MARK: - Computed Properties
    
    private var totalRoles: Int {
        return viewModel.userActivityHistory.count
    }
    
    private var userLevel: String {
        if totalRoles < 40 {
            return "Rolezeiro\nIniciante"
        } else if totalRoles < 100 {
            return "Rolezeiro\nExplorador"
        } else {
            return "Rolezeiro\nVeterano"
        }
    }
    
    private var levelColor: Color {
        if totalRoles < 40 {
            return Color(red: 212/255, green: 175/255, blue: 55/255)
        } else if totalRoles < 100 {
            return Color(red: 212/255, green: 175/255, blue: 55/255)
        } else {
            return .purple
        }
    }
    
    private var isMaxLevel: Bool {
        return totalRoles >= 100
    }
    
    private var nextLevelThreshold: Int {
        if totalRoles < 40 {
            return 40
        } else if totalRoles < 100 {
            return 100
        } else {
            return 100 // Nível máximo
        }
    }
    
    private var progressToNextLevel: Double {
        if totalRoles < 40 {
            return Double(totalRoles) / 40.0
        } else if totalRoles < 100 {
            return Double(totalRoles - 40) / 60.0 // De 40 até 100 (60 rolês de diferença)
        } else {
            return 1.0 // Nível máximo atingido
        }
    }
    
    private var mostFrequentedPlaceThisMonth: (location: FixedLocation, count: Int)? {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        // Filtrar atividades do último mês
        let recentActivities = viewModel.userActivityHistory.filter { activity in
            guard let checkInDate = activity.checkInDate else { return false }
            return checkInDate >= oneMonthAgo
        }
        
        // Contar frequência por local
        var locationCounts: [String: (location: FixedLocation, count: Int)] = [:]
        
        for activity in recentActivities {
            let location = activity.fixedlocation.fixedLocation
            let locationId = location.id
            
            if let existing = locationCounts[locationId] {
                locationCounts[locationId] = (location: location, count: existing.count + 1)
            } else {
                locationCounts[locationId] = (location: location, count: 1)
            }
        }
        
        // Retornar o local mais frequentado
        return locationCounts.values.max { $0.count < $1.count }
    }
}

#Preview {
    ActivityStatsCardView(viewModel: ProfileViewModel())
        .background(Color.fvBackground)
}
