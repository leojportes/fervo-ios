//
//  LocationWithPostsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct LocationWithPosts: Identifiable, Decodable, Equatable {
    static func == (lhs: LocationWithPosts, rhs: LocationWithPosts) -> Bool {
        true
    }

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

struct Coordinates: Codable {
    let lat: Double
    let lng: Double
}

struct Location: Codable {
    let id: String
    let name: String
    let coordinates: Coordinates
    let city: String
    let neighborhood: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case coordinates
        case city
        case neighborhood
        case imageUrl = "image_url"
    }
}

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let userPost: UserPost
    let location: Location
    let photoUrl: String
    let createdAt: Date
    let likes: Int
    let comments: [Comment]?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case userPost = "user_post"
        case location
        case photoUrl = "photo_url"
        case createdAt = "created_at"
        case likes
        case comments
    }
}

struct UserPost: Codable {
    let name: String
    let username: String
    let photoUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case username
        case photoUrl = "photo_url"
    }
}

struct Comment: Codable {
    let userId: String
    let text: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case text
        case createdAt = "created_at"
    }
}
