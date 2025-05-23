//
//  LocationWithPostsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct LocationWithPosts: Identifiable, Decodable, Equatable {
    var id: String {
        return "\(name)-\(city)-\(neighborhood)"
    }

    let name: String
    let city: String
    let neighborhood: String
    let coordinates: Coordinates
    let imageUrl: String
    let posts: [Post]

    enum CodingKeys: String, CodingKey {
        case name, city, neighborhood, coordinates, posts
        case imageUrl = "image_url"
    }
}

struct Coordinates: Codable, Equatable {
    let lat: Double
    let lng: Double
}


