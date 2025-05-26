//
//  RemoteImageView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI

struct RemoteImage: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image

    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
            }
        }
    }

    private var image: Image {
        if let uiImage = loader.image {
            return Image(uiImage: uiImage)
        } else {
            return placeholder
        }
    }
}
