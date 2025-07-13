//
//  StickyHeaderView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct StickyHeaderView: View {
    @State var location: LocationWithPosts
    let onTap: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: location.fixedLocation.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(location.fixedLocation.name)
                            .font(.headline.bold())
                            .foregroundStyle(Color.white)
                        Text(location.placeIsOpen ? "Aberto" : "Fechado")
                            .font(.caption)
                            .foregroundColor(location.placeIsOpen ? .green : .red)
                    }

                    Text(location.fixedLocation.city)
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(
            Color.FVColor.headerCardbackgroundColor.opacity(0.9)
                .background(.ultraThinMaterial.opacity(0.8))
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 10)
        .padding(.horizontal, 8)
        .onTapGesture {
            onTap()
        }
    }
}
