//
//  ImageLoader.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var url: URL?
    private static let cache = NSCache<NSURL, UIImage>()
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0

    init(url: URL?) {
        self.url = url
        load()
    }

    private func load(retriesLeft: Int = 3) {
        guard let url = url else { return }

        // Verifica se a imagem já está no cache
        if let cachedImage = ImageLoader.cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let urlError = error as? URLError, urlError.code == .networkConnectionLost, retriesLeft > 0 {
                print("Network connection lost. Retrying... (\(retriesLeft - 1) attempts left)")
                DispatchQueue.global().asyncAfter(deadline: .now() + self.retryDelay) {
                    self.load(retriesLeft: retriesLeft - 1)
                }
                return
            }

            guard let data = data, let uiImage = UIImage(data: data) else {
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                }
                return
            }

            // Armazena no cache
            ImageLoader.cache.setObject(uiImage, forKey: url as NSURL)

            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}
