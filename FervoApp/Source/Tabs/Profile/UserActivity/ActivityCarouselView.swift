//
//  ActivityCarouselView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 30/08/25.
//

import SwiftUI


struct ActivityCarouselView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.userActivityHistory.prefix(8)) { activity in
                    ActivityCarouselCard(activity: activity)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ActivityCarouselCard: View {
    let activity: UserActivityResponse
    
    var body: some View {
        VStack(spacing: 8) {
            // Foto do local
            RemoteImage(url: URL(string: activity.fixedlocation.fixedLocation.photoURL))
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(spacing: 4) {
                // Nome do local
                Text(activity.fixedlocation.fixedLocation.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                // Quando foi
                Text(activity.checkedInAt.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                // Duração
                Text(activity.formattedDuration)
                    .font(.caption2)
                    .foregroundColor(.blue.opacity(0.8))
            }
        }
        .frame(width: 130, height: 150)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.FVColor.headerCardbackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
