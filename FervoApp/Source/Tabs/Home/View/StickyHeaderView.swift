//
//  StickyHeaderView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct StickyHeaderView: View {
   // let location: LocationWithPosts

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: "")) { image in
               // AsyncImage(url: URL(string: location.photoUrl ?? "")) { image in
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
                        Text("Dont tell Mama")
                            .font(.headline.bold())
                            .foregroundStyle(Color.black)
                      //  Text(location.placeIsOpen ? "Aberto" : "Fechado")
                        Text("Aberto")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                    }

                    Text("Florianópolis")
                        .font(.subheadline)
                        .foregroundColor(.black)
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
            .ultraThinMaterial.opacity(0.9)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 10)
        .padding(.horizontal)
    }
}
