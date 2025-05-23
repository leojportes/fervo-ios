//
//  PostModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct Post: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let userPost: UserModel
    let fixedLocation: FixedLocation
    let image: ImageModel
    let createdAt: Date
    let likes: Int
    let comments: [Comment]?
    let likedBy: [UserModel]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case userPost = "user_post"
        case fixedLocation = "fixed_location"
        case image
        case createdAt = "created_at"
        case likes
        case comments
        case likedBy
    }
}
