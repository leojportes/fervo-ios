//
//  FixedLocation.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import MapKit

struct FixedLocation: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let placeId: String
    let website: String?
    let rating: Double?
    let priceLevel: Int?
    let photoURL: String
    let location: Coordinates
    let weekdayText: [String]?
    let reviews: [Review]?
    let type: String
    let city: String
    let neighborhood: String
    let userRatingTotal: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case placeId
        case website
        case rating
        case priceLevel
        case photoURL
        case location
        case weekdayText
        case reviews
        case type
        case city
        case neighborhood
        case userRatingTotal = "user_rating_total"
    }

    var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    }

    var mapPriceLevelToString: String {
        guard let level = priceLevel, (0...4).contains(level) else {
            return "N/A"
        }
        return String(repeating: "$", count: level)
    }
}

struct Review: Codable, Equatable, Hashable {
    let text: String
    let authorName: String
    let rating: Double

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case text, rating
    }
}
