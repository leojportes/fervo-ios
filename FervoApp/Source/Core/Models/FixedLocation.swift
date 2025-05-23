//
//  FixedLocation.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

struct FixedLocation: Codable, Equatable {
    let id: String
    let name: String
    let placeId: String
    let website: String?
    let rating: Double?
    let priceLevel: Int?
    let localImage: String
    let coordinates: Coordinates
    let weekdayText: [String]
    let reviews: [Review]?
    let type: String
    let city: String
    let neighborhood: String
    let userRatingTotal: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case placeId = "price_id"
        case website
        case rating
        case priceLevel = "price_level"
        case localImage = "local_image"
        case coordinates
        case weekdayText = "weekday_text"
        case reviews
        case type
        case city
        case neighborhood
        case userRatingTotal = "user_rating_total"
    }
}

struct Review: Codable, Equatable {
    let text: String
    let authorName: String
    let rating: Double
}
